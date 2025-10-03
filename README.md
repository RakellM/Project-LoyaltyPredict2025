# Project Loyalty Predict [2025]

Using TeoMeWhy's Loyalty program to create a Data Science project.

You can check TeoMeWhy's material [cursos.teomewhy.org](https://cursos.teomewhy.org) (pt-br).

<br>

# Table of Contents

- [Objective](#objective)
- [Actions](#actions)
- [Requirements](#requirements)
- [Steps](#steps)
- [Data Source](#data-source)


## Objective

Identify user engagement (gain/loss) in TeoMeWhy's community.


## Actions 



## Requirements


## Steps




## Data Source

- [Loyalty System](https://www.kaggle.com/datasets/teocalvo/teomewhy-loyalty-system)
- [Education Platform](https://www.kaggle.com/datasets/teocalvo/teomewhy-education-platform) 


<br>

# EDA

Understanding the data and what is happening to the community engagement.
Good metrics to check is:

- DAU: Daily Active Users
- MAU: Monthly Active Users
- MAU 28 days: Monthly Active User in a 28 days period, or 4 weeks, this way we have a better comparable months, as all weekdays will have the same representativity.

## DAU

With the DAU metric we want to check how many people is engaged on a daily cadence.

<img src="img/dau_over_time.png">

🗨️<b>Notes:</b> \
<i>Notice the high peaks that coincides with Teo's launch course days.
Last one was in Semptember 2025 representing the higher peak.
Another observation here is days that get closer to 0.
It was explained that the tracking system was not live on weekends so it would be somewhat rare to have 0 on certain periods.
Now, their bot is working 24/7 and users can go there even when there is no live streaming just to farm points.</i>

## MAU

MAU metric will smooth out the daily noise.

<img src="img/mau_over_time.png">

🗨️<b>Notes:</b> \
<i>Notice the high peaks in the begining of each year, when people are possibly thinking about changing careers and start watching Teo's courses.
Things seems to not get better as we see a decrease in engagement towards the end of the year.
In September 2025, Teo's SQL course was a success in engagement.</i>


## MAU 28 Days before

With MAU windowed 28 days we have months that are comparable with the same number of weekdays.

<img src="img/mau28_over_time.png">

🗨️<b>Notes:</b> \
<i>The chart is similar to the DAU chart, but now we don't have the noise of 0.
This way we can see how many users remain on that that and the previous 27 days.
Starting of the year attracting more users as we have mentioned, and then it drops towards the end. 
Look how in 2025 the numbers have been going sideways.
Teo needs to keep his users engaged in the community.</i>


## User Life Cycle

There is the need to understand how users behave in the community. 
The scheme below was talked during the course day and consider how the business sees the engagement churn. 
All naming was roughtly translated and since Teo is know as "The Data Wizzard", we have decided to change the names a little, using this magic concept.

<img src="img/Lifecycle_Path.jpg" style='height: 80%; width: 80%; object-fit: contain'>

Definitions:
- curious -> age < 7 days
- faithful -> recency < 7 days AND previous recency < 14 days
- tourist -> 7 <= recency <= 14 days
- unenchanted -> 14 < recency <= 28 days
- zombie -> recency > 28 days
- reconquered -> recency < 7 days AND 14 <= previous recency <= 28 days
- reborn -> recency < 7 days AND previous recency > 28 days

<br>

| Teo's Name | Business Name | Magical Name | Logic |
| ---------- | ------------- | ------------ | ----- |
| Curious | Acquired | Apprendice | age < 7 days |
| Faithful | Retained / Core | Sorcerer | recency < 7 days AND previous recency < 14 days |
| Tourist | Light / Passive | Wondered | 7 <= recency <= 14 days |
| Unenchanted | Churning / Dormant | Fading | 14 < recency <= 28 days |
| Zombie | Lapsed / Inactive | Petrified | recency > 28 days |
| Reconquered | Recovered | Reawakened | recency < 7 days AND 14 <= previous recency <= 28 days |
| Reborn | Resurrected | Resurrected | recency < 7 days AND previous recency > 28 days |

<br>

<img src="img/lifecycle_stacked_bar.png">

🗨️<b>Notes:</b> \
<i>Looking at all the stages that a user can be in the database, except for Zombie/Petrified, Teo's followers are not new.
Expcept at end of August 2025 when we already knew many new comers/Apprendice came for his SQL course, most of his followers are Faithful/Sorcerer.
And even the Apprendices that came in Aug/2025 remained in Sep/2025, as the Sorcerer bar has increased a little.</i>




