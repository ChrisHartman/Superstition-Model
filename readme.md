# Superstition Model

Note: This model is also listed in the [Netlogo Modeling Commons](http://modelingcommons.org/browse/one_model/4633#model_tabs_browse_info), which also includes a web runnable version, though that version is less polished and slower.

## Introduction

This is a model written in NetLogo to demonstrate and analyze the growth of a superstition in society. It explores what factors can lead a community to be more or less superstitious overall. This is accomplished by creating an environment in which there is a chance of coincidences, and by having netlogo turtles respond to those coincidences by either treating them as coincidences or by "believing" that there is a causal relationship.

## What's here?
This repo contains the model, which can be run in [NetLogo](https://ccl.northwestern.edu/netlogo/), along with the full report on the model in pdf form, and the poster used in the poster fair, also in pdf form. 

## What is it?

This is a model intended to examine the growth of a superstition in a population. It offers a more in-depth answer to why superstitions grow than "people just don't understand statistics." It assumes humans are capable of running correct statistical experiments, and that they simply have a lower standard for what is "improbable" than statisticians.

## How it works

Agents move around and keep a log of the last few times they saw a cat, and whether or not that cat was on a red patch. Each time the log changes, they consider the odds that the long has as many or more red patches than it has, this is done using a binomial distribution formula. If the odds are lower than their alpha value, the humans become superstitious, and tell other nearby humans to raise their alpha values. The same happens when they stop being superstitious if they see very few red patches. Every tick, if a human is close to a superstitious human, they increase their own alpha, and if they are close to a non-superstitious human, they decrease it by the same amount or less, depending on their superstition bias.

## How to use it

Use setup and go to set the model up and begin running it. Red-patch-percentage controls how many of the patches become red. Number-of-cats sets the number of cats created on setup. Danger? controls whether or not the humans run away from cats when they are superstitious (simulating that the humans are afraid of red patches and would therefore avoid anything causing them. Memory-length controls how many of their recent cat sightings are remembered by humans. Initial-average-alpha controls the mean of the normal distribution of alphas among the humans. Other-human influence controls how much humans adjust their alphas when another human becomes superstitious or not nearby or when they see at least one superstitious or not superstitious human nearby. Superstition-influence-bias determines how much more humans adjust their alpha based on superstitious humans than based on non-superstitious humans.

## Things to notice

As you can see, with the default values the population becomes superstitious most of the time, or ends up in a "rut". After some time regardless, the population stops changing its beliefs overall. Also notice how the humans who are avoiding the cats tend to group together.

## Things to try

Try turning off danger and seeing if you can adjust the other sliders to still produce a superstitious population. It becomes almost impossible with realistic settings. Another intersting effect is increasing the percentage of red patches or the number of cats even by a small amount. Once again, it prevents the population becomming superstitious.

One very intersting effect is increasing the percentage of red patches while the model is running. Often, this leads to a large jump in superstitious humans, and sometimes it's impossible to revert this jump.

## Extending the model

A potential extension of this model is to improve the communication model. This could include incorperating a network so that humans speak to their friends about their beliefs. Another potential change could be using alpha values to determine how much humans influence each other, instead of just superstitious?.

Another extension could be the incorperation of different types of humans, like skeptics with low alpha values who don't easily shift their alpha values. It could be interesting to see how much impact these skeptics would have, and whether or not they would eventually be convinced.

## Netlogo features

This model makes extensive use of lists. First, lists are used with fput and bl in order to create a deque like data structure, where new memories are added to the top as old memories are removed from the bottom. Another use of lists is in the probability-list, which follows the rule ((item n list) = (memory-length choose n)). This is done by using n-values to create a list of numbers, foreach with a local value to turn that into a list of factorials, and map to use that list of factorials in numerous iterations of the binomial equation. Creating global mathematic values isn't something that occurs very frequently in models, but it makes sense to skip the factorial step being computed every time in this model.

## Related models

Rumor mill is a related simulation of the spread of potentially false information. Another example is the Belief Diffusion model available in the modeling commons.

## Credits and references

Cosmides, L., Tooby, J.: Are humans good intuitive statisticians after all? Rethinking some conclusions from the literature on judgment under uncertainty. Cognition 58, 1–73 (1996)

Beck, J., Forstmeier, W., 2007. Superstition and belief as inevitable byproducts of an adaptive learning strategy. Hum. Nat. 18, 35.

Wilensky, U. (1999). NetLogo [computer software]. Evanston, IL: Center for Connected Learning and Computer-Based Modeling, Northwestern University. http://ccl.northwestern.edu/netlogo .

