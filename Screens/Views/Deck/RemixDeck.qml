import QtQuick 2.0
import CSI 1.0
import './../Widgets' as Widgets
import './../Definitions' as Definitions

//----------------------------------------------------------------------------------------------------------------------
//                                               REMIX DECK
// 
// The remix deck is a row item consisting of four elements. Each element represents one column of the remix decks.
// Each element has a Waveform and two remix cells ( + indicator bars...) 
//----------------------------------------------------------------------------------------------------------------------

Item {
  id: remixDeck
  anchors.fill: parent
  property int    deckId
  
  property string sizeState: "large" // this state is set in Deck.qml and is passed on to each column of the remixDeck. 
  property int rowShift: 1           // rowShift specifies which rows of samples are currently displayed in the remix deck 
  property int lastRowShift: 1
  property bool showLoopSize
  /* #ifdef ENABLE_STEP_SEQUENCER */
  AppProperty { id: sequencerOn;   path: "app.traktor.decks." + (deckId + 1) + ".remix.sequencer.on" }
  readonly property bool showStepSequencer: sequencerOn.value && (screen.flavor != ScreenFlavor.S5)
  /* #endif */
  onRowShiftChanged: {
    remixDeckColumns.sampleRowChangeState = "Unchanged"
    if (rowShift > lastRowShift) {
      remixDeckColumns.sampleRowChangeState = "Increased"
    } else if (rowShift < lastRowShift){
      remixDeckColumns.sampleRowChangeState = "Decreased"
    }     
    remixDeck.lastRowShift = remixDeck.rowShift
  }  
  AppProperty   { id: player1ActiveY; path: remixDeckPropertyPath + "players." + 1  + ".active_cell_row" } 
  AppProperty   { id: player2ActiveY; path: remixDeckPropertyPath + "players." + 2  + ".active_cell_row" } 
  AppProperty   { id: player3ActiveY; path: remixDeckPropertyPath + "players." + 3  + ".active_cell_row" } 
  AppProperty   { id: player4ActiveY; path: remixDeckPropertyPath + "players." + 4  + ".active_cell_row" } 

  //--------------------------------------------------------------------------------------------------------------------
  // These properties are necessary to get the currently active samples from traktor. The remixDeckPropertyPath helps 
  // accessing the AppProperties of the remix deck defined by Traktor. 
  property variant activeValues: [ player1ActiveY.value, player2ActiveY.value, player3ActiveY.value, player4ActiveY.value]
  property string remixDeckPropertyPath: "app.traktor.decks.1.remix." // DEFAULT VALUE. THE REAL PATH IS SET IN DECK.QML 

  Row {
    anchors.fill:         parent
    height:               parent.height
    spacing:              6 // (sizeState == "small") ? 6 : 10
    anchors.leftMargin:   9 // (sizeState == "small") ? 9 : 3
    anchors.rightMargin:  9 // (sizeState == "small") ? 9 : 3
    anchors.topMargin:    (sizeState == "small") ? 3 : 10

    Repeater {  // this repeater creates the four columns of the remix deck
      id: remixDeckColumns
      property string sampleRowChangeState: "Unchanged"
      
      model: 4

      RemixDeckColumn {
        /* #ifdef ENABLE_STEP_SEQUENCER */
        sequencerMode: remixDeck.showStepSequencer
        /* #endif */
        deckId: remixDeck.deckId
        height: parent.height; 
        width: 111; 
        state: sizeState; 
        activeSampleYPosition:  activeValues[index]
        columnPropertyPath: remixDeckPropertyPath + "cell.columns."   + (index + 1); 
        playerPropertyPath: remixDeckPropertyPath + "players." + (index + 1); 
        activeSamplePath:   remixDeckPropertyPath + "cell.columns."   + (index + 1) + ".rows." + (activeValues[index] + 1);
        remixPath:          remixDeckPropertyPath
        sampleRowState:     remixDeckColumns.sampleRowChangeState
      } 
    }
  }
  //--------------------------------------------------------------------------------------------------------------------
  // LoopSize
  //--------------------------------------------------------------------------------------------------------------------

  Widgets.LoopSize {
    id: loopSize
    anchors.centerIn: parent
    visible: (sizeState != "small") && showLoopSize
  }
}
