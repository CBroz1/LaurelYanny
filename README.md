# Laurel Yanny
Publishing data collected based on the bistable auditory illusion.


## About

In May 2018, a small clip went viral as an auditory equivalent of the blue or gold dress. An auditory bistable illusion that sounded like "Laurel" to some and "Yanney" to others. Wired has since published a [video discussing the topic](https://www.youtube.com/watch?v=3km896XZ-J0).

I recognized that an individual's perception would likely shift with pitch shifts. I used ffmpeg to generate shifted versions of the original clip, and concatenated them together in rising and falling sequences, shown [here](https://youtu.be/oaMTXfAZzpE). The original video accumulated about 15k views before I delisted it, and reposted to my personal YouTube. Some commenters requested an even more extreme shift, as shown [here](https://youtu.be/Nu4Ax459hoU).

## EditVideo.sh

This script was made after the fact, with intent to publish to github. After downloading the video, it
1. Crops and measures the original video.
2. Generates pitch shifted versions across a range of kHZ, and labels each
3. Concatenates the new clips into a whole video of: original, rising pitches, original, falling pitches, and again the original.

## Google form

I was interested in when listeners perceived the inflection point between the to words, and whether or not this was linked to demographic information, like age and gender. I posted a [Google form](https://docs.google.com/forms/d/e/1FAIpQLSczFWvoVw_nSRrVZVHnJxplkTFGHJnICps6NLE3z3iz-Cp-NA/viewform?usp=sf_link) to collect this data. It has since 2600+ responses, and one or two still come in each month. Fast implementation of a form taught me some lessons.

1. Google forms, in 2018, did not deal with integer inputs well. Age was therefore collected as a nominal rather than continuous variable.
2. Survey respondents are primarily younger males.
3. Free response location has many issues: 
	* inconsistent *no-response* items (e.g., na vs. n/a)
	* variable strings for the same location
	* variable level of specificity (e.g., USA vs. California vs. San Diego)
3. The absence of a 'feedback' free response resulted in some users providing comments when location was requested as free response. 

If I had anticipated such a global response base, I would have worded this question differently, asking for country and separately asking for city, as well as prompting the user to skip the question if preferring not to respond.


## R Script

The R script is divided into sections for:
1) *Packages:* installing and loading relevant packages into R.
2) *Cleaning:* Accessing and cleaning up the raw data file. Saves processed file. More could be done for the free response data. The cleaned data has the following columns
	* ID: Row ID
	* Orig: Original perception 
	* NumAv: Average inflection point
	* NumUp: Ascending inflection point
	* NumDn: Descending inflection point
	* ChangeUp: Does it change going up?
	* ChangeDn: Does it change going down?
	* ChangeBt: Does it change either way?
	* Gender: M, F, and NB for Gender-fluid/Non-binary/Other
	* Age: High end of binned ranges from ordinal question. '65' for >60.
	* LocUS: Nominal region within US. 
3) *Stats:* Statistical tests.
4) *SPSS Code:* legacy SPSS code

## Results

My first pass at the data with SPSS can be found [here](https://imgur.com/a/IClnLh4). The conclusions are similar, but the relationship between original interpretation and directional inflection points no longer differs by gender.

1. Women are more likely to hear Yanney.
2. Interpretations are preserved with pitch changes. Inflection points are higher when going up and lower coming down. 
3. Splitting results by original interpretation and gender.
	* Women have higher inflection points than men.
	* The gender gap is smaller among those who initially heard Laurel.
4. Age, when treated as continuous, is a significant predictor of
	* Original perception. Greater perception of Laurel with age, but trend is driven by relatively few older respondents.
	* Inflection point. Youngest and oldest respondents have highest and lowest inflection points respectively. 

<center>
<img src="https://github.com/CBroz1/LaurelYanny/blob/master/LY_Boxplot.png" width="400">
</center>
