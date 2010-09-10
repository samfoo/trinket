Trinket
=======

Working is boring. Trinket is a game that makes it fun. 

How does this--what did you call it? widget, doohicky--... trinket thing work?
------------------------------------------------------------------------------

Trinket is simple: 

When your users do something in your application -- like closing or opening 
a bug -- your application tells Trinket about it. Trinket is very smart and knows
about all kinds of stuff that has happened before. Sometimes, Trinket thinks
someone is pretty cool for what they have done and gives them a badge.

What the heck is a badge?
-------------------------

Badges are a cool award that users "win" for doing cool stuff. You get to
define your own badges. It's easy, check it out:

    badge "Kill Frenzy" do
      is_one_time_only
      event_must_have_occurred("status", 
                               :value => "closed",
                               :within => 1.day,
                               :times => 10)
    end

Or this one is pretty gnarly:

    badge "Zerg Queen" do
      is_one_time_only
      must_have_acheived "Zergling"
      event_must_have_occurred("status",
                               :value => "opened",
                               :times => 50)
    end

Why do I want badges?
---------------------

Here are some very good and very serious reasons that you want to collect 
badges:

* They look good on a tuxedo. 
* If you get enough, Richard Branson will fly you to space. With supermodels.
* Pumpkin pie.
