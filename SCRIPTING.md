# Scripting Language

## General

The script for a trial is formatted as a `.script` text file containing only the following:

* Non-indented lines beginning with commands, which appear fully capitalized
* Indented lines containing parameters for the previous command
* Comment lines beginning with `//`, which are ignored by the engine.

Additionally, whenever you see `[location]` below, it may be one of the following:
- COURT_DEFENSE
- COURT_PROSECUTION
- COURT_JUDGE
- COURT_WITNESS
- COURT_ASSISTANT

## Initialization

The following *must* be configured prior to their use.

### Characters
`CHARACTER_LOCATION` will set characters to a specific background, so when you cut to that background they are there

    CHARACTER_INITIALIZE [name] [folder location]
    CHARACTER_LOCATION [name] [location]


Example:

    CHARACTER_INITIALIZE Phoenix characters/phoenix
    CHARACTER_LOCATION Phoenix COURT_DEFENSE


### Evidence

    EVIDENCE_INITIALIZE [internal name] [external name] [description] [asset file]
    COURT_RECORD_ADD [internal name]

Example:

    EVIDENCE_INITIALIZE BrokenWineGlass "Broken Wine Glass" "It's sharp and pointy, useful for murder." evidence/broken_wine_glass.png
    COURT_RECORD_ADD BrokenWineGlass

## Cross-Examination and Definitions

Similar to Initializations, these *must* be configured prior to their use.

### Trial Fail Condition

Every trial **must** have TRIAL_FAIL defined at the start of the trial; this determines what happens when the player runs out of exclamation points.

    DEFINE_TRIAL_FAIL
        [Actions that should happen]
        GAME_OVER
    
    END_DEFINE

Example:

    DEFINE TRIAL_FAIL
        JUMPCUT COURT_JUDGE
        SPEAK Judge
            "yooooooo phoenix you lost bro"
    
        GAME_OVER
    END_DEFINE

### Cross Examination "Presses"

The Cross Examination phase of the game requires a "Press" to be defined for each statement given by the witness.

If the press is considered valid (i.e. it won't issue a penalty), you can define it as follows:

    DEFINE [internal name for this Press]
        HOLD_IT [character name]
        [Actions that should happen]
    
    END DEFINE

Example:

    DEFINE Press1
        HOLD_IT Phoenix
        JUMPCUT COURT_DEFENSE
        SPEAK Phoenix
            "Are you sure it was 4:30PM?"
    
        JUMPCUT COURT_WITNESS
        SPEAK Gumshoe
            "The time sounds about right, pal. the body was still slightly warm when we got there"
    
        JUMPCUT COURT_DEFENSE
        SPEAK Phoenix
            "When did you get there?"
    
        JUMPCUT COURT_WITNESS
        SPEAK Gumshoe
            "Just before 4:45, and you won't believe this..."
    
    END_DEFINE

**Note**: The "Press" actions should end with the camera on the court witness, so that the cross examination should continue.

### Cross Examination Presenting Evidence

Presenting the wrong evidence will warrant a penalty, and this action is defined as follows:

    DEFINE [internal name for this Press]
        OBJECTION [character name]
        [Actions that should happen]
    
        ISSUE_PENALTY
        JUMPCUT COURT_WITNESS
    END_DEFINE

**Note**: You probably want dialogue from the defense for the actual "objection".

Example:

    DEFINE CrossExamineFail
        OBJECTION Phoenix
        JUMPCUT COURT_DEFENSE
        SPEAK Phoenix
            "i uhhhh object to that!"
    
        JUMPCUT COURT_JUDGE
        SPEAK Judge
            "hahaha phoenix you wrong"
    
        ISSUE_PENALTY
        JUMPCUT COURT_WITNESS
    END_DEFINE

## Cross Examination

The cross examination phase will be a block formatted like the following:

    CROSS_EXAMINATION [name] "[initial text]" [name of failure definition]
        "[statement 1]" [name of corresponding Press] [conflicting evidence (or 0 if none)]

Example:

    CROSS_EXAMINATION Gumshoe "-- ten minutes is all i need, baby --" CrossExamineFail
        "the victim died from huffing spraypaint" PressA1 BrokenWineGlass
        "at 4:30 pm on the 19th" PressA2 0
        "daniel sexbang was there at the scene of the crime when we arrived!" PressA3 0

Once the correct conflicting evidence is presented, the script will continue on past the `CROSS_EXAMINATION`

## Available Actions

### Configure Music

    PLAY_MUSIC [music name]

Music File Name is expect to be one of the pre-defined music files in `main.lua`:
- TRIAL
- OBJECTION
- SUSPENCE
- QUESTIONING_ALLEGRO
- QUESTIONING
- PRELUDE
- LOGIC_AND_TRICK

Example:

    PLAY_MUSIC TRIAL

### Switch Characters

    JUMPCUT [location]

### Trigger dialogue from a specific character

    SPEAK [name]
        "[dialogue]"

Example:

    SPEAK Judge
        "Now starting a trial."


### Switch Characters and also trigger dialogue from the character assigned to that location
This function is just JUMPCUT and SPEAK combined into one, because it can be tedious writing both every time.

    SPEAK_FROM [location]
        "[dialogue]"

Example:

    SPEAK_FROM COURT_WITNESS
        "time for a cross examination!"

### Raise an objection
[name] is who is objecting.

    OBJECTION [name]

### Yell "hold it!"
[name] is who is yelling it.

    HOLD_IT [name]
