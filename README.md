# SeqLearning

This project implements a framework for learning on sequential data. The framework includes an implementation 
of the Perceptron algorithm for sequential data and several implementation of "decoding algorithms" (a Viterbi
classifier and our own CarpeDiem classifier).

The framework should compile without warnings on recent XCode environment [[1](#note1)]. To be used the framework
needs to be installed in /Library/Frameworks and referenced from the requiring application. 

# Installation

Open the project from XCode and build it. Find the SeqLearning.framework package inside the Products folder in XCode,
right click on it an select "Show in Finder", then copy the file in /Library/Frameworks.

<a name="note1">This version has been tested on XCode 8.0</a>
