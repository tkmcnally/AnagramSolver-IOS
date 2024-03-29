// This program tests the validity of a Blitzkrieg DAWG file, and demonstrates the new Dawg-Node configuration.
// Updated on Monday, December 29, 2011.

#include <stdlib.h>
#include <string.h>
#include <dirent.h>

#include <CoreFoundation/CoreFoundation.h>
#include "AnagramFinder.h"

#define MAX_WORD_LENGTH 15
#define MAX 15
#define MAX_INPUT 120
#define BIG_IT_UP -32
#define LOWER_IT 32
#define SIZE_OF_CHARACTER_SET 26
#define WILD_CARD '?'
#define DAWG_DATA "Traditional_Dawg_For_Word-List"
#define WORD_LIST_OUTPUT "New_Dawg_Word_List.txt"

// These values define the format of the "Dawg" node encoding.
#define CHILD_BIT_SHIFT 10
#define END_OF_WORD_BIT_MASK 0X00000200
#define END_OF_LIST_BIT_MASK 0X00000100
#define LETTER_BIT_MASK 0X000000FF

// Define the boolean type as an enumeration.
//typedef enum Bool {FALSE = 0, TRUE = 1};
//typedef Bool* BoolPtr;

// When reading strings from a file, the new-line character is appended, and this macro will remove it before processing.
#define CUT_OFF_NEW_LINE(string) (string[strlen(string) - 1] = '\0')

// For speed, define these two simple functions as macros.  They modify the "LettersToWorkWith" string in the recursive anagrammer.
#define REMOVE_CHAR_FROM_STRING(thestring, theposition, shiftsize) ( memmove(thestring + theposition, thestring + theposition + 1, shiftsize) )
#define INSERT_CHAR_IN_STRING(ts, tp, thechar, shiftsize) ( (memmove(ts + tp + 1, ts + tp, shiftsize)), (ts[tp] = thechar) )

// These are the predefined characters that exist in the DAWG data file.
const unsigned char CharacterSet[SIZE_OF_CHARACTER_SET] = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };

// Enter the graph at the correct position without scrolling through a predefined list of level "0" nodes.
const unsigned char EntryNodeIndex[SIZE_OF_CHARACTER_SET] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26 };


//Globals
int NumberOfNodes;
int *TheDawgArray;
FILE *Lexicon;
FILE *WordList;
_Bool FetchData = TRUE;
unsigned char FirstChar;
int InputSize;


typedef struct {
    unsigned char **array;
    size_t used;
    size_t size;
} Array;

void initArray(Array *a, size_t initialSize) {
    a->array = (unsigned char **) malloc(initialSize * sizeof(unsigned char *));
    a->used = 0;
    a->size = initialSize;
}

void insertArray(Array *a, unsigned char *element) {
   
    if (a->used == a->size) {
        a->size *= 2;
        a->array = realloc(a->array, a->size * sizeof(unsigned char *));
    }
    a->array[a->used] = (unsigned char *)malloc(MAX_WORD_LENGTH);
    memcpy(a->array[a->used], element, MAX_WORD_LENGTH);
    a->used++;
}

void freeArray(Array *a) {
    free(a->array);
    a->array = NULL;
    a->used = a->size = 0;
}

// This function converts any lower case letters in the string "RawWord", into capitals, so that the whole string is made of capital letters.
void MakeMeAllCapital(char *RawWord){
    int X;
    for ( X = 0; X < strlen(RawWord); X++ ){
        if ( RawWord[X] >= 'a' && RawWord[X] <= 'z' ) RawWord[X] = RawWord[X] + BIG_IT_UP;
    }
}

// This function removes any char from "ThisString" which does not exist in "CharacterSet".
void RemoveIllegalChars(unsigned char *ThisString){
    int X;
    int Y;
    int Length = strlen(ThisString);
    for ( X = 0; X < Length; X++ ) {
        if ( ThisString[X] == WILD_CARD ) goto CheckNextPosition;
        for ( Y = 0; Y < SIZE_OF_CHARACTER_SET; Y++ ) {
            if ( ThisString[X] == CharacterSet[Y] ) goto CheckNextPosition;
        }
        // The "char" in position "X" is illegal.
        memmove(ThisString + X, ThisString + X + 1, Length - X);
        X -= 1;
        Length -= 1;
    CheckNextPosition:;
    }
}

// Return the index position of character "ThisChar", as it appears in "CharacterSet", and it must exist in the set.
unsigned char CharToIndexConversion(unsigned char ThisChar){
    int Y;
    if ( ThisChar == WILD_CARD ) return 255;
    for ( Y = 0; Y < SIZE_OF_CHARACTER_SET; Y++ ) {
        if ( ThisChar == CharacterSet[Y] ) return Y;
    }
    return NULL;
}

// This is a simple Bubble Sort.
void Alphabetize(unsigned char *Word){
    int X;
    int Y;
    int WildCardCount = 0;
    unsigned char WorkingChar;
    int WordSize = strlen(Word);
    for( X = 1; X < WordSize; X++ ) {
        for( Y = 0; Y <= (WordSize - X - 1); Y++ ) {
            if ( CharToIndexConversion(Word[Y]) > CharToIndexConversion(Word[Y + 1]) ) {
                WorkingChar = Word[Y + 1];
                Word[Y + 1] = Word[Y];
                Word[Y] = WorkingChar;
            }
        }
    }
    if ( Word[WordSize - 1] == WILD_CARD ) {
        for ( X = WordSize - 1; X >= 0; X-- ) {
            if ( Word[X] == WILD_CARD ) WildCardCount += 1;
        }
        memmove(Word + WildCardCount, Word, WordSize - WildCardCount);
        memset(Word, WILD_CARD, WildCardCount);
    }
}

// Define the "Dawg" functionality as macros for speed.  "DAWG_CHILD(d" Now uses only a single bit shift operation.
#define DAWG_LETTER(thearray, theindex) (thearray[theindex]&LETTER_BIT_MASK)
#define DAWG_END_OF_WORD(thearray, theindex) (thearray[theindex]&END_OF_WORD_BIT_MASK)
#define DAWG_NEXT(thearray, theindex) ((thearray[theindex]&END_OF_LIST_BIT_MASK)? 0: theindex + 1)
#define DAWG_CHILD(thearray, theindex) (thearray[theindex]>>CHILD_BIT_SHIFT)

// A recursive depth first traversal of "TheDawg" lexicon to produce a readable wordlist in "TheStream".
void DawgTraverseLexiconRecurse(unsigned int *TheDawg, int CurrentIndex, int FillThisPosition,
                                char *WorkingString, int *TheCount, FILE *TheStream){
    int PassOffIndex;
    WorkingString[FillThisPosition] = DAWG_LETTER(TheDawg, CurrentIndex);
    if ( DAWG_END_OF_WORD(TheDawg, CurrentIndex) ) {
        *TheCount += 1;
        WorkingString[FillThisPosition + 1] = '\0';
        // Include the Windows Carriage Return char.
        //fprintf(TheStream, "|%6d|-|%-15s|\r\n", *TheCount, WorkingString);
    }
    if ( PassOffIndex = DAWG_CHILD(TheDawg, CurrentIndex) ) DawgTraverseLexiconRecurse(TheDawg,
                                                                                       PassOffIndex, FillThisPosition + 1, WorkingString, TheCount, TheStream);
    if ( PassOffIndex = DAWG_NEXT(TheDawg, CurrentIndex) ) DawgTraverseLexiconRecurse(TheDawg,
                                                                                      PassOffIndex, FillThisPosition, WorkingString, TheCount, TheStream);
}

// Move through "ThisDawg" lexicon, and print the words into "ThisStream".
void DawgTraverseLexicon(unsigned int *ThisDawg, FILE *ThisStream){
    char *BufferWord = (char*)malloc((MAX + 1)*sizeof(char));
    int *WordCounter = (int*)malloc(sizeof(int));
    *WordCounter = 0;
    // Include the Windows Carriage Return char.
    //fprintf(ThisStream, "This is the lexicon contained in the file |%s|.\r\n\r\n", DAWG_DATA);
    DawgTraverseLexiconRecurse(ThisDawg, 1, 0, BufferWord, WordCounter, ThisStream);
    free(BufferWord);
    free(WordCounter);
}

// This function is the core component of this program.
// It requires that "UnusedChars" be in alphabetical order because the tradition Dawg is a list based structure.
void DawgAnagrammerRecurse(int *DawgOfWar, int CurrentIndex, unsigned char *ToyWithMe,
                           int FillThisPosition, unsigned char *UnusedChars, int SizeOfBank, int *ForTheCounter, _Bool WildCard, Array *resultSet){
    int X;
    char PreviousChar = '\0';
    char CurrentChar;
    int TempIndex = DAWG_CHILD(DawgOfWar, CurrentIndex);
    
    ToyWithMe[FillThisPosition] = DAWG_LETTER(DawgOfWar, CurrentIndex) + (WildCard? LOWER_IT: 0);
    
    if ( DAWG_END_OF_WORD(DawgOfWar, CurrentIndex) ) {
        *ForTheCounter += 1;
        ToyWithMe[FillThisPosition + 1] = '\0';
        //printf("|%4d| - |%-15s|%s\n", *ForTheCounter, ToyWithMe, SizeOfBank? "\0": "--> TRUE ANAGRAM");
       
        insertArray(resultSet, ToyWithMe);
        
    }
    if ( (SizeOfBank > 0) && (TempIndex != 0) ) {
        for ( X = 0; X < SizeOfBank; X++ ) {
            CurrentChar = UnusedChars[X];
            if ( CurrentChar == PreviousChar ) continue;
            if ( CurrentChar == WILD_CARD ) {
                REMOVE_CHAR_FROM_STRING(UnusedChars, X, SizeOfBank - X);
                while ( TempIndex ) {
                    DawgAnagrammerRecurse(DawgOfWar, TempIndex, ToyWithMe, FillThisPosition + 1,
                                          UnusedChars, SizeOfBank - 1, ForTheCounter, TRUE, resultSet);
                    TempIndex = DAWG_NEXT(DawgOfWar, TempIndex);
                }
                INSERT_CHAR_IN_STRING(UnusedChars, X, CurrentChar, SizeOfBank - X);
                TempIndex = DAWG_CHILD(DawgOfWar, CurrentIndex);
            }
            else {
                do {
                    if ( CurrentChar == DAWG_LETTER(DawgOfWar, TempIndex) ) {
                        REMOVE_CHAR_FROM_STRING(UnusedChars, X, SizeOfBank - X);
                        DawgAnagrammerRecurse(DawgOfWar, TempIndex, ToyWithMe, FillThisPosition + 1,
                                              UnusedChars, SizeOfBank - 1, ForTheCounter, FALSE, resultSet);
                        INSERT_CHAR_IN_STRING(UnusedChars, X, CurrentChar, SizeOfBank - X);
                        TempIndex = DAWG_NEXT(DawgOfWar, TempIndex);
                        break;
                    }
                    else if ( CurrentChar < DAWG_LETTER(DawgOfWar, TempIndex) ) break;
                } while ( TempIndex = DAWG_NEXT(DawgOfWar, TempIndex) );
            }
            if ( TempIndex == 0 ) break;
            PreviousChar = CurrentChar;
        }
    }
}

// This function uses "MasterDawg" to determine the words that can be made from the letters in "CharBank".
// The words will be displayed in alphabetical order according to "CharacterSet[]".
// The return value is the total number of words found.
int DawgAnagrammer(int *MasterDawg, unsigned char * CharBank, Array *resultSet){
    int X;
    int Y;
    int Result;
    int BankSize = strlen(CharBank);
    int *ForTheCount = (int*)malloc(sizeof(int));
    unsigned char *TheWordSoFar = (char*)malloc((MAX + 1)*sizeof(char));
    unsigned char *LettersToWorkWith = (unsigned char*)malloc(MAX_INPUT*sizeof(unsigned char));
    unsigned char PreviousChar = '\0';
    unsigned char CurrentChar;
    int NumberOfLetters;
    int CurrentEntryNode;
    strcpy(LettersToWorkWith, CharBank);
    Alphabetize(LettersToWorkWith);
    NumberOfLetters = strlen(LettersToWorkWith);
    
    *ForTheCount = 0;
    for ( X = 0; X < BankSize; X++ ) {
        CurrentChar = LettersToWorkWith[X];
        // Move to the next letter if we have already processed the "CurrentChar".
        if ( CurrentChar == PreviousChar ) continue;
        if ( CurrentChar == WILD_CARD ) {
            REMOVE_CHAR_FROM_STRING(LettersToWorkWith, X, NumberOfLetters - X);
            for ( Y = 0; Y < SIZE_OF_CHARACTER_SET; Y++ ) {
                if ( EntryNodeIndex[Y] ) {
                    DawgAnagrammerRecurse(MasterDawg, EntryNodeIndex[Y], TheWordSoFar, 0, LettersToWorkWith,
                                          NumberOfLetters - 1, ForTheCount, TRUE, resultSet);
                }
            }
            INSERT_CHAR_IN_STRING(LettersToWorkWith, X, CurrentChar, NumberOfLetters - X);
            PreviousChar = CurrentChar;
            continue;
        }
        // Make sure not to enter the graph if NO words begin with "CurrentChar".
        CurrentEntryNode = EntryNodeIndex[CharToIndexConversion(CurrentChar)];
        if ( !CurrentEntryNode ) {
            PreviousChar = CurrentChar;
            continue;
        }
        REMOVE_CHAR_FROM_STRING(LettersToWorkWith, X, NumberOfLetters - X);
        DawgAnagrammerRecurse(MasterDawg, CurrentEntryNode, TheWordSoFar, 0, LettersToWorkWith,
                              NumberOfLetters - 1, ForTheCount, FALSE, resultSet);
        INSERT_CHAR_IN_STRING(LettersToWorkWith, X, CurrentChar, NumberOfLetters - X);
        PreviousChar = CurrentChar;
    }
    Result = *ForTheCount;
    free(ForTheCount);
    free(TheWordSoFar);
    free(LettersToWorkWith);
    return Result;
}


unsigned char ** mainHelper(const char *DecisionInput) {
    Array resultSet;
    initArray(&resultSet, MAX_WORD_LENGTH);  // initially 5 elements
    
    MakeMeAllCapital(DecisionInput);
    RemoveIllegalChars(DecisionInput);
    InputSize = strlen(DecisionInput);

    if(InputSize >= 2) {
        DawgAnagrammer(TheDawgArray, DecisionInput, &resultSet);
    }
    unsigned char *a = "A";
    unsigned char *i = "I";
    if(strchr(DecisionInput, 'A')) {
        insertArray(&resultSet, a);
    }
    if(strchr(DecisionInput, 'I')) {
        insertArray(&resultSet, i);
    }
    
    unsigned char *eor = "_EOR";
    insertArray(&resultSet, eor);
    return resultSet.array;
}

int initializeDawg(const char * filePath) {
    Lexicon = fopen(filePath, "rb");
    fread(&NumberOfNodes, sizeof(int), 1, Lexicon);
    TheDawgArray = (int *)malloc(NumberOfNodes*sizeof(int));
    fread(TheDawgArray, sizeof(int), NumberOfNodes, Lexicon);
    fclose(Lexicon);

    return 0;
}

