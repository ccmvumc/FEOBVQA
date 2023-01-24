import pandas as pd


def suvr_stats(csv_path):
    '''Load the csv file and add the values to the stats dictionary'''

    # Load stats from csv file
    dfc = pd.read_csv(csv_path, sep=',', header=0)
    dfc_mean = dfc[['ROI', 'MEAN']].copy()
    mean_stats = dict(zip(dfc_mean.ROI, dfc_mean.MEAN))

    # Get SUVR
    d = mean_stats['supravwm_eroded']
    suvr_stats = {f'{k}_suvr': (float(v) / d) for k, v in mean_stats.items()}

    return suvr_stats


def write_stats(stats, file_path):
    '''Write stats to file as key=value'''

    with open(file_path, 'w') as stats_file:
        for key, value in sorted(stats.items()):
            stats_file.write(f'{key}={value}\n')


def run(stats_file):
    csv_path = '/OUTPUTS/DATA/PETbyROI.csv'
    stats = suvr_stats(csv_path)
    write_stats(stats, stats_file)


if __name__ == '__main__':
    stats_file = '/OUTPUTS/stats.txt'
    run(stats_file)
