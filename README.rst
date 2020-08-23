token - Token Reward System Manager
===================================

`token` is a command line tool designed to organize and manage token rewards.
`token` allows users to add, delete, list token rewards, make graphical
representations of them and plot history of past tokens to track progress.


What is Token Reward System?
----------------------------

Token Reward System is one of the tools designed to combat procrastination.
The basic idea is to reward completion of unpleasant tasks by giving yourself
some token rewards (referred simply as *tokens*) in order to offset the
unpleasantness of the task.

`token` application stores each token reward in plain text files and assumes
that each reward has a short description, date when this reward was earned and
a reward value (in range 1-10).


Installation
------------

`token` is written in Nim_ programming language, which is a lean language with
python like syntax directly translated into C. To compile `token` you would
need a Nim_ runtime and a nimble_ package manager available on your system.

The easiest way to compile and install `token` is by running ``make``

::

    make install

You can control installation paths via ``PREFIX``, ``DESTDIR`` variables.

.. _Nim: https://nim-lang.org/
.. _nimble: https://github.com/nim-lang/nimble


Documentation
-------------

Please refer to the manpage ``token (1)`` for the complete documentation.

Usage Examples
^^^^^^^^^^^^^^

Add a new token reward

::

    $ token add installed token application --reward 5

List all rewards

::

    $ token list

List all rewards that have a word *install* in the description and have been
earned after 1999-01-01

::

    $ token list '.*install.*' --after 1999-01-01

Draw an iconic representation of earned rewards in a terminal

::

    $ token itable

Draw a graph of earned rewards grouped by week

::

    $ token graph --mode week

