# SNOWPACK_iceshelves_melt
Scripts to process SNOWPACK output for calculating melt on Antarctic ice shelves. Note that this workflow requires basic [R](https://www.r-project.org/) for calculating means and standard deviations.

This repository was used to produce the SNOWPACK model analysis used in: Banwell, A., Wever, N., Dunmire, D. and Picard, G. (2023): Quantifying Antarctic-wide ice-shelf surface melt volume using microwave and firn model data: 1980 to 2021. Geophys. Res. Lett. (accepted).

# Steps to reproduce:

## Postprocessing
First, the SNOWPACK output needs to be processed to get relevant output. This is done by the script `postprocess.sh`. Make sure that the following is set correctly in the beginning of the script:
- `zipdir_snowpackoutput`: set this variable to the exact path where the zipped SNOWPACK output files, archived at doi: [10.5281/zenodo.7956517](https://doi.org/10.5281/zenodo.7956517), are stored
- `postprocessdir="${HOME}/postprocess/"`: set this variable to a path where the postprocessed files should be stored, for example `${HOME}/postprocess/`. Note that most scripts here assume that the postprocessed files are in `./postprocess/`.
- `snowpack_tools_dir="${HOME}/snowpack/Source/snowpack/tools/`: the scripts needs a tool that is in the SNOWPACK source code. Point to the exact path of the `snowpack/Source/snowpack/tools/` path in the [SNOWPACK repository](https://doi.org/10.5281/zenodo.7956900).

Then execute:
```
bash postprocess.sh
```

## Calculating the melt water statistics

First, modify the first couple of lines in `calc_stats.sh` and `calc_stats_per_day.sh` to set the following:
- `experiment_tag="ICESHELVES"`: Provide the simulation tag, which is ICESHELVES for the simulations published at doi: [10.5281/zenodo.7956517](https://doi.org/10.5281/zenodo.7956517).
- `lt=1`: If set to 1, the analysis is done in local time. If set to 0, analysis is done in UTC time, the time zone in which the simulations were run. `lt=1` is what has been used in the study.
- `fullday=0`: If set to 1, 24 hr period (00:00-00:00) is analyzed. If set to 0, analysis is restricted between 6:00-10:00 and 18:00-22:00. `fullday=0` is what has been used in the study.

Then execute:
```
bash calc_stats.sh
```
and
```
bash calc_stats_per_day.sh
```
Note that the script `bash calc_stats.sh` is designed with some amount of parallelization, since the script allows for 4 tasks to be independently executed. If a number between 1 and 4 is provided as the first command line parameter (e.g., `bash postprocess.sh 2`), only the corresponding task (2 in this case) is executed. When omitted, all tasks are run sequentially.

The output from the script `calc_stats.sh` is stored in the folders `stats` and `stats_iceshelves` when `fullday==1`, or `stats622` and `stats_iceshelves622` when `fullday==0`. The output from the script `calc_stats_per_day.sh` is stored in the folders `stats_per_day` and `stats_iceshelves_per_day` when `fullday==1`, or `stats_per_day622` and `stats_iceshelves_per_day622` when `fullday==0`. Calculations for the 8 regions are stored in `stats`, `stats622`, `stats_per_day`, and `stats_per_day622`, whereas output for the ice shelves are stored in `stats_iceshelves`, `stats_iceshelves622`, `stats_iceshelves_per_day`, and `stats_iceshelves_per_day622`. The mapping of MERRA-2 points per region can be found in the file `points_regions_4.45km.txt`, and similarly for the ice shelves in `points_ice_shelves_4.45km.txt`.
For each ice shelf and region, the following files are created:

- melt\_R*X*.txt and melt\_S*X*.txt: sum of melt amount (kg/m2) for region R*X* or ice shelf S*X*, respectively.
- meltdays\_*A*mm_R*X*.txt and meltdays\_*A*mm_S*X*.txt: number of days exceeding *A* mm of melt for region R*X* or ice shelf S*X*, respectively.
- mswater\_*A*mm_R*X*.txt and mswater\_*A*mm_S*X*.txt: number of days with total firn column water content exceeding *A* kg/m2 for region R*X* or ice shelf S*X*, respectively.
- mswater*A*\_*B*\_*C*mm_R*X*.txt and mswater*A*\_*B*\_*C*mm_S*X*.txt: number of days with more than _C_ kg/m2 amount of liquid water in the firn between _A_ and _B_ meters below the surface for region R*X* or ice shelf S*X*, respectively.

Each of the files report the year, respectively the date, in the first column, followed by the statistics for each grid point in the region/ice shelf, followed by the mean and standard deviation over all grid points in the respective region/ice shelf listed in the preceding columns. The first line is a header.

To find out the sequence by which MERRA-2 points appear in the output columns, execute the script `list_points.sh` using `bash list_points.sh`, which produces such a list. The list is constructed as follows. First there is a header indicating that what follows are regions. Then, each line contains a comma-delimited list of the region number, latitude, and longitude, respectively. The first line for a region is reported in the column with header `1` in the statistics file, the second line in the column with header `2`, and so on. After all regions are listed, there is again a header line denoting that what follows are the ice shelves. Similar to the section for the regions, each following line contains a comma-delimited list of the ice shelf number, latitude, and longitude, respectively. Note that the numbering of regions and ice shelves is listed in the headers of the files `points_regions_4.45km.txt` and `points_ice_shelves_4.45km.txt`, respectively.

Note: the output from this workflow, with settings `lt=1` and `fullday=0` in the scripts `calc_stats.sh` and `calc_stats_per_day.sh`, can be found at doi: [10.5281/zenodo.7956517](https://doi.org/10.5281/zenodo.7956517), in the file `statistics.zip`. The output from the script `list_points.sh` is contained in that archive file as `list_points.txt`.


## Calculating monthly means of forcing variables
The script `calc_monthly_means.sh` contains code that was used to calculate monthly statistics of the forcing variables TA (air temperature, K), QI (specific humidity, -), ILWR (incoming longwave radiation W/m2), ISWR (incoming shortwave radiation, W/m2), PSUM (precipitation, kg/m2/h), and VW (wind speed, m/s). The output from these files is stored in the folders `monthlystats` for the regions and `monthlystats_iceshelves` for the ice shelves. Each file name contains the forcing variable and the region/ice shelf number. The numbering of regions and ice shelves is listed in the headers of the files `points_regions_4.45km.txt` and `points_ice_shelves_4.45km.txt`, respectively. Each file then contains the month (expressed as YYYYMM), followed by means of the specific variable for each MERRA-2 grid point in the region/ice shelves (in the same sequence as for the statistics files discussed above), followed by the mean and standard deviation over all MERRA-2 grid points listed in the preceding columns.

Notes:
- The output from this workflow can be found at doi: [10.5281/zenodo.7956517](https://doi.org/10.5281/zenodo.7956517), in the file `forcingstatistics.zip`. The output from the script `list_points.sh`, denoting the column mapping to MERRA-2 grid points, is also contained in that archive file as `list_points.txt`. See details above.
- The script would require the input meteorological forcing in the form of `*smet` files to reproduce the monthly statistics files, which are not stored in the repository due to the large amounts of additional storage that would be required. With some modifications to the script, it would be possible to perform similar calculations using the output `*.smet` files from the SNOWPACK model, archived at doi: [10.5281/zenodo.7956517](https://doi.org/10.5281/zenodo.7956517).
