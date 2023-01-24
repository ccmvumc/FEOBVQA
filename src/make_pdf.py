
from __future__ import print_function
import math
import os
from datetime import datetime
import numpy as np
import pandas as pd
import nibabel as nib
from numpy.ma import masked_array, masked_inside
import matplotlib
from matplotlib.colors import ListedColormap
matplotlib.use('Agg')
import matplotlib.pyplot as plt


ROI_CMAP = ListedColormap([
    (0.0, 1.0, 0.0),  # 1 Ant Frontal
    (0.0, 1.0, 1.0),  # 2 Lateral Parietal
    (1.0, 1.0, 0.0),  # 3 Lateral Temporal
    (0.6, 0.2, 1.0),  # 4 Ant Cingulate
    (1.0, 0.0, 1.0),  # 5 Post Cingulate
    (1.0, 0.5, 0.0),  # 6 Cerebellum GM
    (0.0, 0.0, 1.0)   # 7 Cerebellum WM
])


def plot_slices(
    bg_file, fg_file, prows, pcols, row,
    xhair=False, fg_interp='nearest',
    fg_cmap='autumn', fg_alpha=1.0,
    axlm_slice_loc=0.5, beta=False, name='', show_title=False
):
    zoom_radius = 110

    if isinstance(fg_cmap, ListedColormap):
        fg_vmax = len(fg_cmap.colors) + 1
    else:
        fg_vmax = 0

    # Load the images
    bg = nib.load(bg_file)
    bg_data = cropad_data(bg, zoom_radius)

    if fg_file:
        fg = nib.load(fg_file)
        fg_data = np.squeeze(fg.get_data())
        fg_data = cropad_data(fg, zoom_radius)
    else:
        fg_data = np.empty(bg_data.shape)
        fg_data[:] = np.NAN

    if beta:
        fg_data = masked_inside(fg_data, -0.25, 0.25)
    else:
        fg_data = masked_array(fg_data, fg_data == 0)

    # Calculate slice numbers
    axlm_slice_num = int(bg_data.shape[2] * axlm_slice_loc)
    cora_slice_num = int(bg_data.shape[1] * 0.33)
    corp_slice_num = int(bg_data.shape[1] * 0.66)
    sagl_slice_num = int(bg_data.shape[0] * 0.33)
    sagr_slice_num = int(bg_data.shape[0] * 0.66)

    # Calculate aspects
    bg_hdr = bg.header
    bg_aspect = [
        bg_hdr['pixdim'][3] / bg_hdr['pixdim'][1],
        bg_hdr['pixdim'][3] / bg_hdr['pixdim'][1],
        bg_hdr['pixdim'][3] / bg_hdr['pixdim'][2]
    ]

    # Get the bg slice data
    bg_axlm_slice = fliptrans(bg_data[:, :, axlm_slice_num])
    bg_cora_slice = fliptrans(bg_data[:, cora_slice_num, :])
    bg_corp_slice = fliptrans(bg_data[:, corp_slice_num, :])
    bg_sagl_slice = fliptrans(bg_data[sagl_slice_num, :, :])
    bg_sagr_slice = fliptrans(bg_data[sagr_slice_num, :, :])

    # Get the gm slice data
    fg_axlm_slice = fliptrans(fg_data[:, :, axlm_slice_num])
    fg_cora_slice = fliptrans(fg_data[:, cora_slice_num, :])
    fg_corp_slice = fliptrans(fg_data[:, corp_slice_num, :])
    fg_sagl_slice = fliptrans(fg_data[sagl_slice_num, :, :])
    fg_sagr_slice = fliptrans(fg_data[sagr_slice_num, :, :])

    if xhair:
        # Make the crosshair image
        bg_shape = bg_data.shape
        xhair_axlm_slice = np.full([bg_shape[0], bg_shape[1]], np.nan)
        xhair_axlm_slice[sagl_slice_num, :] = 1
        xhair_axlm_slice[sagl_slice_num + 1, :] = 1
        xhair_axlm_slice[sagr_slice_num, :] = 1
        xhair_axlm_slice[sagr_slice_num + 1, :] = 1
        xhair_axlm_slice[:, cora_slice_num] = 1
        xhair_axlm_slice[:, cora_slice_num + 1] = 1
        xhair_axlm_slice[:, corp_slice_num] = 1
        xhair_axlm_slice[:, corp_slice_num - 1] = 1
        xhair_axlm_slice = np.fliplr(np.flipud(np.transpose(xhair_axlm_slice)))

    # Show the coronal anterior slice
    ax = plt.subplot2grid((prows, pcols), (row, 1), rowspan=2, colspan=2)
    ax.imshow(
        bg_corp_slice, cmap='gray', aspect=bg_aspect[1],
        interpolation='bilinear'
    )
    ax.imshow(
        fg_corp_slice, cmap=fg_cmap, aspect=bg_aspect[1],
        interpolation=fg_interp, alpha=fg_alpha, vmin=0, vmax=fg_vmax
    )
    plt.ylabel(name)
    plt.tick_params(axis='both', which='both',
                    bottom='off', top='off',
                    labelbottom='off', right='off', left='off',
                    labelleft='off')
    ax.grid(False)

    if show_title:
        ax.set_title('Anterior', fontsize=10)

    # Show the sagittal right slice
    ax = plt.subplot2grid((prows, pcols), (row, 3), rowspan=2, colspan=2)
    ax.imshow(
        bg_sagr_slice, cmap='gray', aspect=bg_aspect[2],
        interpolation='bilinear'
    )
    ax.imshow(
        fg_sagr_slice, cmap=fg_cmap, aspect=bg_aspect[2],
        interpolation=fg_interp, alpha=fg_alpha, vmin=0, vmax=fg_vmax
    )
    ax.set_axis_off()
    if show_title:
        ax.set_title('Right', fontsize=10)

    # Show the axial slice
    ax = plt.subplot2grid((prows, pcols), (row, 5), rowspan=2, colspan=2)
    ax.imshow(
        bg_axlm_slice, cmap='gray', aspect=bg_aspect[0],
        interpolation='bilinear'
    )
    ax.imshow(
        fg_axlm_slice, cmap=fg_cmap, aspect=bg_aspect[0],
        interpolation=fg_interp, alpha=fg_alpha, vmin=0, vmax=fg_vmax
    )
    ax.set_axis_off()
    if xhair:
        ax.imshow(
            xhair_axlm_slice, cmap='winter_r', aspect=bg_aspect[0],
            interpolation='nearest'
        )
    if show_title:
        ax.set_title('Axial', fontsize=10)

    # Show the sagittal left slice
    ax = plt.subplot2grid((prows, pcols), (row, 7), rowspan=2, colspan=2)
    ax.imshow(
        bg_sagl_slice, cmap='gray', aspect=bg_aspect[2],
        interpolation='bilinear'
    )
    ax.imshow(
        fg_sagl_slice, cmap=fg_cmap, aspect=bg_aspect[2],
        interpolation=fg_interp, alpha=fg_alpha, vmin=0, vmax=fg_vmax
    )
    ax.set_axis_off()
    if show_title:
        ax.set_title('Left', fontsize=10)

    # Show the coronal post slice
    ax = plt.subplot2grid((prows, pcols), (row, 9), rowspan=2, colspan=2)
    ax.imshow(
        bg_cora_slice, cmap='gray', aspect=bg_aspect[1],
        interpolation='bilinear'
    )
    ax.imshow(
        fg_cora_slice, cmap=fg_cmap, aspect=bg_aspect[1],
        interpolation=fg_interp, alpha=fg_alpha, vmin=0, vmax=fg_vmax
    )
    ax.set_axis_off()
    if show_title:
        ax.set_title('Posterior', fontsize=10)


def fliptrans(slice_data):
    return np.fliplr(np.flipud(np.transpose(slice_data)))


# Crop and pad data to zoom_radius
def cropad_data(img, zoom_radius):
    hdr = img.header
    img_data = np.squeeze(img.get_data())
    xshape = int(zoom_radius * 2 / hdr['pixdim'][1])
    yshape = int(zoom_radius * 2 / hdr['pixdim'][2])
    zshape = int(zoom_radius * 2 / hdr['pixdim'][3])

    if xshape > img_data.shape[0]:
        xcrop = img_data.shape[0]
    else:
        xcrop = xshape

    if yshape > img_data.shape[1]:
        ycrop = img_data.shape[1]
    else:
        ycrop = yshape

    if zshape > img_data.shape[2]:
        zcrop = img_data.shape[2]
    else:
        zcrop = zshape

    xlb = int(img_data.shape[0] / 2 - xcrop / 2)
    xub = xlb + xcrop
    ylb = int(img_data.shape[1] / 2 - ycrop / 2)
    yub = ylb + ycrop
    zlb = int(img_data.shape[2] / 2 - zcrop / 2)
    zub = zlb + zcrop

    img_data = img_data[xlb:xub, ylb:yub, zlb:zub]

    # Now pad any dimensions smaller than radius
    xdim = img_data.shape[0]
    ydim = img_data.shape[1]
    zdim = img_data.shape[2]
    xpad = xshape - xdim
    ypad = yshape - ydim
    zpad = zshape - zdim
    npad = (
        (int(math.ceil(xpad / 2.0)), int(math.floor(xpad / 2.0))),
        (int(math.ceil(ypad / 2.0)), int(math.floor(ypad / 2.0))),
        (int(math.ceil(zpad / 2.0)), int(math.floor(zpad / 2.0)))
    )

    pad_value = int(math.floor(img_data.min()))
    if pad_value > 0:
        pad_value = 0

    img_data = np.pad(
        img_data, pad_width=npad, mode="constant", constant_values=pad_value
    )
    return img_data


def run():
    prows = 16
    pcols = 12
    stats = {}

    # Outputs
    job_dir = '/OUTPUTS/DATA'
    stats_path ='/OUTPUTS/stats.txt'
    csv_path = os.path.join(job_dir, 'PETbyROI.csv')
    seg_path = os.path.join(job_dir, 'ROI_SEG.nii.gz')
    cortwm_path = os.path.join(job_dir, 'ROI_cortwm.nii.gz')
    pdf_path = os.path.join(job_dir, 'report.pdf')
    gm_path = os.path.join(job_dir, 'ROI_cortgm.nii.gz')
    wm_path = os.path.join(job_dir, 'ROI_cortwm.nii.gz')
    pet_mc_path = os.path.join(job_dir, 'PET_mcf_meanvol.nii.gz')

    # Load PET image
    print('Loading PET image:' + pet_mc_path)
    pet_data = nib.load(pet_mc_path).get_data()

    # Load SEG image
    print('Loading SEG image:' + seg_path)
    seg_data = nib.load(seg_path).get_data()

    # Load WM image
    print('Loading WM image:' + cortwm_path)
    cortwm_seg_data = nib.load(cortwm_path).get_data()

    pet_data[pet_data <= 0.0] = np.nan
    cortwm_data = pet_data[[cortwm_seg_data == 1]]
    tot_data = pet_data[[seg_data > 0]]
    tot_mean = np.nanmean(tot_data)
    flobe_data = pet_data[[seg_data == 1]]
    plobe_data = pet_data[[seg_data == 2]]
    tlobe_data = pet_data[[seg_data == 3]]
    acing_data = pet_data[[seg_data == 4]]
    pcing_data = pet_data[[seg_data == 5]]
    cblmgm_data = pet_data[[seg_data == 6]]
    cblmwm_data = pet_data[[seg_data == 7]]
    compgm_data = pet_data[[(seg_data <= 5) & (seg_data > 0)]]
    cblmtot_data = pet_data[[(seg_data == 6) | (seg_data == 7)]]

    # Data for bar plot
    both_data = {
        'Ant Frontal': len(flobe_data),
        'Lat Parietal': len(plobe_data),
        'Lat Temporal': len(tlobe_data),
        'Ant Cingulate': len(acing_data),
        'Post Cingulate': len(pcing_data),
        'Cerebellar GM': len(cblmgm_data),
        'Cerebellar WM': len(cblmwm_data)
    }
    col_list = [
        'Ant Frontal', 'Lat Parietal', 'Lat Temporal',
        'Ant Cingulate', 'Post Cingulate',
        'Cerebellar GM', 'Cerebellar WM']
    plot_df = pd.DataFrame(both_data, [''], columns=col_list)

    # Data for boxplots
    plot_data = [
        flobe_data, plobe_data, tlobe_data,
        acing_data, pcing_data,
        cblmgm_data, cblmwm_data,
        cortwm_data, cblmtot_data, compgm_data]

    # Labels for boxplots
    plot_labels = [
        'Ant\nFrontal',
        'Lat\nParietal',
        'Lat\nTemporal',
        'Ant\nCingulate',
        'Post\nCingulate',
        'Cerebellar GM',
        'Cerebellar WM',
        'Cerebral WM',
        'Cerebellum',
        'Composite GM'
    ]

    # Data for SUVR table
    with open(stats_path) as f:
        suvr = {x.rstrip().split('=')[0]: x.rstrip().split('=')[1] for x in f}

    # Create the main container figure for the page
    fig = plt.figure(0, figsize=(7.5, 10))

    # Plot Image Slices
    plot_slices(
        pet_mc_path, None, prows, pcols, 1, name='PET',
        xhair=True, show_title=True)
    plot_slices(pet_mc_path, gm_path, prows, pcols, 3, name='GM')
    plot_slices(pet_mc_path, wm_path, prows, pcols, 5, name='WM')
    plot_slices(
        pet_mc_path, seg_path, prows, pcols, 7, name='ROI',
        fg_cmap=ROI_CMAP)

    # Top text
    axes = plt.subplot2grid((prows, pcols), (0, 0), rowspan=1, colspan=8)
    axes.text(
        0, 1, 'DAX Report - FEOBV',
        horizontalalignment='left',
        verticalalignment='top',
        fontsize=14, fontweight='bold'
    )
    axes.set_axis_off()

    # Bar Plot of voxel counts
    axes = plt.subplot2grid((prows, pcols), (10, 0), rowspan=1, colspan=12)
    plot_df.plot(
        kind='barh', stacked='true', ax=axes, cmap=ROI_CMAP, fontsize=6)
    axes.set_xlabel('Voxel Count', fontsize=6)
    axes.legend(
        ncol=8, fontsize=6, loc='upper center', bbox_to_anchor=(0.5, 1.5))

    # Boxplots of raw values
    axes = plt.subplot2grid((prows, pcols), (12, 0), rowspan=3, colspan=8)
    axes.boxplot(plot_data, labels=plot_labels, showfliers=False)
    xlabels = axes.get_xticklabels()
    for label in xlabels:
        label.set_rotation(90)
        label.set_fontsize(6)

    # Draw mean line
    axes.axhline(y=tot_mean, linewidth=1, color='g', ls='dashed')

    # Plot Table
    columns = ['SUVR']
    rows = [
        'Ant Frontal', 'Lat Parietal', 'Lat Temporal',
        'Ant Cingulate', 'Post Cingulate',
        'Cerebellar GM', 'Cerebellar WM',
        'Cerebral WM', 'Cerebellum', 'Composite GM']
    cell_text = [
        [suvr.get('flobe_suvr')],
        [suvr.get('plobe_suvr')],
        [suvr.get('tlobe_suvr')],
        [suvr.get('acing_suvr')],
        [suvr.get('pcing_suvr')],
        [suvr.get('cblmgm_suvr')],
        [suvr.get('cblmwm_suvr')],
        [suvr.get('cortwm_suvr')],
        [suvr.get('cblmtot_suvr')],
        [suvr.get('compgm_suvr')]]

    ax = plt.subplot2grid((prows, pcols), (12, 11), rowspan=4, colspan=2)
    ax.set_axis_off()
    the_table = ax.table(cellText=cell_text,
                         rowLabels=rows,
                         colLabels=columns,
                         loc='center',
                         cellLoc='center')
    the_table.auto_set_font_size(False)
    the_table.set_fontsize(9)

    # Tidy up margins
    fig.tight_layout(pad=2)
    fig.subplots_adjust(wspace=0.1, hspace=0.1)

    # Save figure to PDF file
    pdf_page1_path = os.path.splitext(pdf_path)[0] + '_page1.pdf'
    fig.savefig(
        pdf_page1_path, transparent=True, orientation='portrait', dpi=300)
    plt.close(fig)

    # Concatenate PDFs
    cmd = 'gs -q -sPAPERSIZE=letter -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile='
    cmd += pdf_path + '  ' + os.path.splitext(pdf_path)[0] + '_page*.pdf'
    print('INFO:saving final PDF:' + cmd)
    os.system(cmd)


if __name__ == '__main__':
    run()
