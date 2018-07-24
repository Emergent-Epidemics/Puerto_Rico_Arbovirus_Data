# Puerto Rico Arbovirus Data
We are digitizing the weekly arbovirus reports from the Departamento de Salud in Puerto Rico.  They are originally provided as PDFs.  Please see the original data here  http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/.  It's really critical to point out that we haven't yet performed proper validation on these data and would very much welcome contributors who are either interested in suggesting code changes, validating data, and/or contributing new data sets.

## Informes Arbovirales

### Filename

Data/Informes_Arbovirales_1532444481.14413-years-2016-2017-2018.csv

### Puerto Rico level data on arboviruses between 2016 - present

The first data set we've completed is Informes Arbovirales.  These PDFs report weekly confirmed cases of dengue (DENV), chikungunya (CHIKV), Zika (ZIKV), and filoviruses--along with suspected cases of arboviral diseases--on a weekly basis.  The cumulative columns are the running cumulative for each disease for the year (and it appears as though 2017 includes 2016) and it's possible for the difference in sequential weeks to be negative because cases can be "back corrected" causing a reduction in the total number of cumulative cases.  The "new" columns are the number of new cases reported that week.  However, they are reported as running 3-4 week totals.  The "Group" column contains the weeks one needs to use to generate the new case counts for that week.  We plan on writing code to parse these and organize them, but haven't yet completed that work.

## San Juan Dengue Data

### Filename

Data/san_juan_dengue_data.csv

### San Juan dengue data for the 1990/1991 to 2012/2013 dengue seasons 
Description
The dataset contains weekly dengue data for the San Juan-Carolina-Caguas Metropolitan Statistical Area. The dataset includes the following variables: 

* season: the transmission season; 
* season_week: week of the season (not the calendar year - the season starts following the week with historically lowest dengue cases over the years 1990-2009); 
* week_start_date: date of the first day of the week; 
* denv1_cases: number of laboratory confirmed cases with DENV1; 
* denv2_cases: number of laboratory confirmed cases with DENV2; 
* denv3_cases: number of laboratory confirmed cases with DENV3; 
* denv4_cases: number of laboratory confirmed cases with DENV4; 
* other_positive_cases: laboratory-positive cases without serotype identified (these include acute IgM positive and IgM conversions); 
* additional_cases: at times not all specimens submitted were tested due to overload of the capacity for testing or incomplete case information. For those weeks, the number of additional laboratory-positive cases among those not tested was estimated by multiplying the number of untested cases by the rate of laboratory-positive cases amongst those that were tested; 
* total_cases: the sum of all cases (denv1-4_cases + other_positive_cases + additional_cases), the target time series for forecasting.

Over time, the sensitivity of testing increased, particularly in 2005 when PCR was implemented for routine diagnostics, in 2007 when improved IgM testing was implemented, and in 2009 when a more sensitive PCR assay was adopted. Details are presented in Sharp et al. 2010.

Sharp TM, Hunsperger E, Santiago GA, Muñoz-Jordan JL, Santiago LM, Rivera A, et al. (2013) Virus-Specific Differences in Rates of Disease during the 2010 Dengue Epidemic in Puerto Rico. PLoS Negl Trop Dis 7(4): e2159. doi:10.1371/journal.pntd.0002159 

### Last Update
May 18, 2015 

### Publisher
Puerto Rico Department of Health and Centers for Disease Control and Prevention 

### Contact Name and Email
Michael Johansson, mjohansson@cdc.gov 

### Public Access Level
Public 

### License
Creative Commons Attribution 4.0 (http://creativecommons.org/licenses/by/4.0/legalcode) 

## Additional license, warranty, and copyright information
We provide a license for our code (see LICENSE) and do not claim ownership, nor the right to license, the data we have obtained.  Please cite the Departamento de Salud in Puerto Rico in publications using these data and please contact them regarding the legal use of these data.  As a reminder, THE DATA AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA AND/OR SOFTWARE OR THE USE OR OTHER DEALINGS IN THE DATA AND/OR SOFTWARE.
