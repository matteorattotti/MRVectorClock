# MRVectorClock

MRVectorClock is an Objective-C implementation of a [Vector Clock](http://en.wikipedia.org/wiki/Vector_clock).
Vector clocks are useful when implementing synchronisation in a distributed system (iCloud for example).

## Installation

Drag the **MRVectorClock.m** and **MRVectorClock.h** files in your project.

`#import "MRVectorClock.h"` into the classes you want to use it and you're all set.

## Features

MRVectorClock provide most of the basic features you'll need using a Vector Clock:

- [Create a Vector Clock](https://github.com/matteorattotti/MRVectorClock#create-a-mrvectorclock)
- [Update Vector Clock values](https://github.com/matteorattotti/MRVectorClock#update-vector-clock-values)
- [Vector Clock Comparison](https://github.com/matteorattotti/MRVectorClock#vector-clock-comparison)
- [Merging Vector Clocks](https://github.com/matteorattotti/MRVectorClock#merging-vecto-clocks)
- [Serialization and Deserialization](https://github.com/matteorattotti/MRVectorClock#serialization-and-deserialization)

#### Create a MRVectorClock
Newly created vector clock start out with a value of `0`.
```Objective-C
// Instantiating a new vector clock
MRVectorClock *vectorClock = [MRVectorClock new];
```
#### Update vector clock values
Each event that concern the vector clock should update its value by 1.
```Objective-C
[vectorClock updateClockValueForID:@"An Identifier"];
```
`"An Identifier"` triggered the update event, the state of the vector clock will now be `("An Identifier":1)`.

 It's also possible to pass a set value to the update.
 ```Objective-C
[vectorClock updateClockValueForID:@"An Identifier" value: 17];
```
 This will set the state of the vector clock to `("An Identifier":17)`

#### Vector clock comparison
The main feature of vector clocks is the ability to compare them in order to know if they are the same, a descendant, an ancestor or if they are concurrent.
 ```Objective-C
switch ([vectorClock compare:secondVectorClock]) {
   case MRVectorClockOrderedSame:       // both have the same values
       break;
   case MRVectorClockOrderedAncestor:   // vectorClock is an earlier version of secondVectorClock
       break;
   case MRVectorClockOrderedDescendant: // vectorClock is an new version of secondVectorClock
       break;
   case MRVectorClockOrderedConcurrent: // vector clocks are concurrent
       break;
}

```

#### Merging vector clocks
Vector clocks can be merged together into a new vector clock, this new clock will be a descendant of the others. This means that the resulting vector clock will have all the max values of the others clocks.
 ```Objective-C
// (A:2, B:1)
MRVectorClock *vectorClock = [MRVectorClock new];
[vectorClock updateClockValueForID:@"A" value:2];
[vectorClock updateClockValueForID:@"B" value:1];

// (A:1, B:2, C:3)
MRVectorClock *secondVectorClock = [MRVectorClock new];
[vectorClock updateClockValueForID:@"A" value:1];
[vectorClock updateClockValueForID:@"B" value:2];
[vectorClock updateClockValueForID:@"C" value:3];

// Merged clock -> (A:2, B:2, C:3)
MRVectorClock *mergedVectorClock = [vectorClock mergeClock:secondVectorClock];
```

#### Serialization and Deserialization
MRVectorClock instances can be serialized and it's possibile to instantiate new vector clocks for the serialized data:
 ```Objective-C
// (A:1)
MRVectorClock *vectorClock = [MRVectorClock new];
[vectorClock updateClockValueForID:@"A"];

// Serializing the clock
NSData *clockData = [vectorClock data];

// Getting a new clock from the serialized data
MRVectorClock *newVectorClock = [[MRVectorClock alloc]initWithData:clockData];
```

#### Unit Tests

Unit tests are included, to run the tests, open the Xcode workspace, choose the MRVectorClockTests target in the toolbar at the top, and select the menu item `Product > Test`.

## License
This project is distributed under the standard MIT License. Please use this in whatever fashion you wish - feel free to recommend any changes to help the code.
