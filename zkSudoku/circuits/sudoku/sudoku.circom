pragma circom 2.0.0;

// circomlib module is a collection of pre-built circuits in Circom
// comparators.circom contains definitions for GreaterThan, GreaterEqThan, LessThan, LessEqThan, and Equal gates
include "../node_modules/circomlib/circuits/comparators.circom";

// in Circom, a template is a program that defines a circuit
// it doesn't have state, but it can have inputs and outputs (signals) and how they should be processed
// templates in Circom are used to create zk-SNARKs circuits
template Sudoku() {

    // unsolved is a private input signal. It is the unsolved sudoku
    // it is a 9x9 matrix of 32-bit unsigned integers
    // i's two-dimensional (2d) arrays of 9 rows and 9 columns each
    signal input unsolved[9][9];
    // solved is a private output signal. It is the solved sudoku
    // it is a 9x9 matrix of 32-bit unsigned integers
    // i's two-dimensional (2d) arrays of 9 rows and 9 columns each
    signal input solved[9][9];

    // component is a keyword used to define a reusable block of circuitry that can be used in other circuits
    // each element in the arrays getone and letnine is a component that has been defined elsewhere in the circuit
    // i's two-dimensional (2d) arrays of 9 rows and 9 columns each
    // for example, getone[0][0] would refer to the first element in the first row of the getone array
    component getone[9][9];
    component letnine[9][9];

    // Check if the numbers of the solved sudoku are >=1 and <=9
    // Each number in the solved sudoku is checked to see if it is >=1 and <=9
    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
           letnine[i][j] = LessEqThan(32);
           letnine[i][j].in[0] <== solved[i][j];
           letnine[i][j].in[1] <== 9;

           getone[i][j] = GreaterEqThan(32);
           getone[i][j].in[0] <== solved[i][j];
           getone[i][j].in[1] <== 1;

           letnine[i][j].out ===  getone[i][j].out;
        }
    }


    // Check if unsolved is the initial state of solved
    // If unsolved[i][j] is not zero, it means that solved[i][j] is equal to unsolved[i][j]
    // If unsolved[i][j] is zero, it means that solved [i][j] is different from unsolved[i][j]

    component ieBoard[9][9];
    component izBoard[9][9];

    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            ieBoard[i][j] = IsEqual();
            ieBoard[i][j].in[0] <== solved[i][j];
            ieBoard[i][j].in[1] <== unsolved[i][j];

            izBoard[i][j] = IsZero();
            izBoard[i][j].in <== unsolved[i][j];

            ieBoard[i][j].out === 1 - izBoard[i][j].out;
        }
    }


    // component called ieRow that stores an array of 324 IsEqual components
    // Check if each row in solved has all the numbers from 1 to 9, both included
    // For each element in solved, check that this element is not equal
    // to previous elements in the same row

    component ieRow[324];

    var indexRow = 0;

    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            for (var k = 0; k < j; k++) {
                ieRow[indexRow] = IsEqual();
                ieRow[indexRow].in[0] <== solved[i][k];
                ieRow[indexRow].in[1] <== solved[i][j];
                ieRow[indexRow].out === 0;
                indexRow ++;
            }
        }
    }


    // Check if each column in solved has all the numbers from 1 to 9, both included
    // For each element in solved, check that this element is not equal
    // to previous elements in the same column

    component ieCol[324];

    var indexCol = 0;


    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            for (var k = 0; k < i; k++) {
                ieCol[indexCol] = IsEqual();
                ieCol[indexCol].in[0] <== solved[k][j];
                ieCol[indexCol].in[1] <== solved[i][j];
                ieCol[indexCol].out === 0;
                indexCol ++;
            }
        }
    }


    // Check if each square in solved has all the numbers from 1 to 9, both included
    // For each square and for each element in each square, check that the
    // element is not equal to previous elements in the same square

    component ieSquare[324];

    var indexSquare = 0;

    for (var i = 0; i < 9; i+=3) {
       for (var j = 0; j < 9; j+=3) {
            for (var k = i; k < i+3; k++) {
                for (var l = j; l < j+3; l++) {
                    for (var m = i; m <= k; m++) {
                        for (var n = j; n < l; n++){
                            ieSquare[indexSquare] = IsEqual();
                            ieSquare[indexSquare].in[0] <== solved[m][n];
                            ieSquare[indexSquare].in[1] <== solved[k][l];
                            ieSquare[indexSquare].out === 0;
                            indexSquare ++;
                        }
                    }
                }
            }
        }
    }

}

// unsolved is a public input signal. It is the unsolved sudoku
component main {public [unsolved]} = Sudoku();
