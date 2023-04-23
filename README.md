# simpleRace

## Introduction

This project is a BeamMP mod that allows you to race with friends on your BeamMP server.

## Table of contents

* [Installation](#installation)
* [How to play](#how-to-play)

## Installation

Copy the content of `BeamMP_simpleRace/Server/*` to your server folder `BeamMP_Server/Resources/Server/`.

Go to the `BeamMP_simpleRace/Client` folder and create a zip archive named `simpleRace.zip` and with the following architecture :

```
simpleRace.zip
|-lua
|    |-ge
|       |- ...
|-scripts
|    |-simpleRace
|       |- ...
```

Copy the `simpleRace.zip` archive to `BeamMP_Server/Resources/Client/`.



That's it, just run your server and you're ready to play with your friends.

## How to use

List of commands :

```
/help                    [SR] Display the list of commands
/startrace               [SR] Start a race
/stoprace                [SR] Stop the race
/setlap [nb_laps]        [SR] Set the number of lap for the race
```