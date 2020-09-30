# Factorio-Science-Off

A competitive science usage mod that tracks science packs used and awards points for them.

Features
============

- A small GUI will show your progress of current science packs and points. Plus any time or point goal you are competing against.
- Your progress in science packs and points can be seen in the production graph.
- You can load previous play data and compete against it, with the target science packs and points shown in the production graph with a graph logo over them. This gives you a built in equivalent to time splits in speed runs. At the end of the run you will get the option to export this data for use in future runs. This exported data can be loaded prior to a run via the Target Run Data setting.
- At the end of a run (time or points limit reached) the game will freeze and you can review your base and production graph. See the runtime settings for the 2 types of game freezing (Editor Mode or Spectator).
- Option to have a timestamped points written to chat console for recording milestones and for streamer chat. Interval controlled by mod setting.
- A togglable GUI to show the science pack points value.

Science Pack Point Values
=================

For every science pack used to do science you will be awarded points at the below rates. These rates are based on raw ingredient costs and craft time. The science packs usage is based on the consumption graph. So you can change research without any real loss of points.
*Using productivity modules will score you less points per research as you consumed less packs.*

Science Pack | Point Value
------------ | -------------
Automation Science | 1
Logistic Science | 3
Military Science | 6
Chemical Science | 10
Production Science | 34
Utility Science | 38
Space Science | 80

Hints and Weird Factorio 'Features'
=================

- Chaining labs together with inserters can "lose" science packs counted due to a long standing bug/limitation/feature in Factorio and how it counts consumption data. Just do straight inserts in to a single lab and it will behave normally.
- You can launch space science packs in a rocket and it will be counted as consumed because Factorio returns you fish for them. However, this is obviously very expensive compared to using it in a lab. Maybe edge cases when this is advantageous?

Notes
===========

- Changing any startup mod settings once the map has been created is not supported. You must start a new map if any startup mod settings need changing. Given the short term playing time of the mod this shouldn't be an issue.
- Currently only supports vanilla science pack types, but is expandable in theory.
- Currently only supports 1 team ("player") per map. However, the code is written with the possible extension to support multiple forces in mind.