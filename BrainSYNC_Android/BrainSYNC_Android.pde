// BrainSYNC
// Developed by Conor Russomanno
// conor.russomanno@gmail.com

/*-------------Data Storage Method:-----------------------------------------
 All data entries will begin with a classifier number
 0 - EEG Data
 1 - activity data
 2 - mood data
 
 followed by: 
 
 a date (MM/DD/YYYY) + "," + time (HH:MM:SS) + "," +
 
 activity & mood data entries will be classified by a numerical indicator 1-11 
 and (1-10 being the preset options, 11 being custom)
 ----------------------------------------------------------------------------*/

/* Program States
 
 0 - Open - App Intro (Tap to continue)
 1 - Select Bluetooth Module
 2 - Annotate
 3 - Your Brain
 4 - Share
 5 - Settings
 6 - select activity
 7 - select mood
 8 - inputActivity
 9 - inputMood
 10 - BT check
 
 sub-states:
 
 inputButtonPressed:
 0 - nothing
 1 - start
 2 - instant
 3 - i did this
 4 - i felt this  
 */

import guicomponents.*;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import java.util.ArrayList;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import android.os.Environment;

//---------------------------------
private static final int REQUEST_ENABLE_BT = 3;
ArrayList dispositivos;
BluetoothAdapter adaptador;
BluetoothDevice dispositivo;
BluetoothSocket socket;
InputStream ins;
OutputStream ons;
boolean registrado = false;
//PFont f1;
//PFont f2;
int estado;
String error = "Error";
String incomingData;
String EEGToSD;

int numRead;
String tempEEG = "Start!$";

int elegido = 100;

BroadcastReceiver receptor = new BroadcastReceiver()
{
  public void onReceive(Context context, Intent intent)
  {
    //println("onReceive");
    String accion = intent.getAction();

    if (BluetoothDevice.ACTION_FOUND.equals(accion))
    {
      BluetoothDevice dispositivo = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
      //println(dispositivo.getName() + " " + dispositivo.getAddress());
      dispositivos.add(dispositivo);
    }
    else if (BluetoothAdapter.ACTION_DISCOVERY_STARTED.equals(accion))
    {
      estado = 0;
    }
    else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(accion))
    {
      estado = 1;
      //println("end search");
    }
  }
};

//---------------------------------
//for clock
import java.lang.System;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

SimpleDateFormat formatterDate = new SimpleDateFormat("MM/dd/yyyy");
SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss a");   

//program variables
int state = 0;

long msTime;
String filePath = Environment.getExternalStorageDirectory().toString() + "/Test.csv"; // change the path to adapt to your system
PImage state0;
PImage state1;
PImage state2;
PImage state3;
PImage state4;
PImage state5;
PImage state6;
PImage state7;
PImage highlightSelection;
PImage iDidThisPressed;
PImage iFeltThisPressed;
PImage inputActivity;
PImage inputMood;
PImage instantPressed;
PImage startPressed;

//booleans for activity activation
//correlate to activityNumber 0-10
int numActivities = 12;
boolean [] activityNumber = new boolean[numActivities];
String [] activityString = new String[25];

//booleans for mood activation
//correlate to moodNumber 0-10
int numMoods = 12;
boolean [] moodNumber = new boolean[numMoods];
String [] moodString = new String[25];

int selectedActivity;
int selectedMood;

//boolean _confirmActivity = false;
//boolean _confirmMood = false;
//converted to states 8 and 9

int confirmSelection = 0; // 1 = start, 2 = instant, 3 = i did this, 4 = i felt this

//Dropdown menus for input choices
GCombo activityDropdown, moodDropdown;

PFont f1;
PFont f2;

void setup() {
  size(displayWidth, displayHeight);
  orientation(PORTRAIT); //sketch stays in portrait mode, even when rotated
  frameRate(60);
  textAlign(CENTER);
  f1 = loadFont("BlairMdITCTT-Medium-24.vlw");
  f2 = createFont("Arial", 10, true);
  textFont(f1, 24);

  //load image assets
  state0=loadImage("state0.png");
  state1=loadImage("state1.png");
  state2=loadImage("state2.png");
  state3=loadImage("state3.png");
  state4=loadImage("state4.png");
  state5=loadImage("state5.png");
  state6=loadImage("state6.png");
  state7=loadImage("state7.png");
  highlightSelection=loadImage("highlightSelection.png");
  iDidThisPressed=loadImage("iDidThisPressed.png");
  iFeltThisPressed=loadImage("iFeltThisPressed.png");
  inputActivity=loadImage("inputActivity.png");
  inputMood=loadImage("inputMood.png");
  instantPressed=loadImage("instantPressed.png");
  startPressed=loadImage("startPressed.png");

  activityString[0] = "napping";
  activityString[1] = "exercising";
  activityString[2] = "eating";
  activityString[3] = "drinking coffee";
  activityString[4] = "reading";
  activityString[5] = "in class";
  activityString[6] = "working";
  activityString[7] = "watching tv";
  activityString[8] = "gaming";
  activityString[9] = "meditating";
  activityString[10] = "custom";

  moodString[0] = "productive";
  moodString[1] = "happy";
  moodString[2] = "angry";
  moodString[3] = "tired";
  moodString[4] = "anxious";
  moodString[5] = "calm";
  moodString[6] = "energetic";
  moodString[7] = "depressed";
  moodString[8] = "fucosed";
  moodString[9] = "nervous";
  moodString[10] = "custom";

  for (int i = 0; i<numActivities; i++) {
    activityNumber[i]=false;
  }
  for (int i = 0; i<numMoods; i++) {
    moodNumber[i]=false;
  }
}

void draw () {
  //if bluetooth packet received, write to SD
  //----------------from spanish BT------------

  //---------------------------------

  //Draw Appropriate State
  if (state==0) {
    image(state0, 0, 0);
  }
  else if (state==1) {
    //draw from spanish BT example
    switch(estado)
    {
    case 0:
      listaDispositivos("Looking For Devices", color(255, 0, 0));
      break;
    case 1:
      listaDispositivos("Select Device", color(0, 255, 0));
      break;
    case 2:
      conectaDispositivo();
      break;
    case 3:
      state=2;
      break;
    case 4:
      muestraError();
      break;
    }
  }
  else if (state==2) {
    image(state2, 0, 0);
  }
  else if (state==3) {
    image(state3, 0, 0);
  }
  else if (state==4) {
    image(state4, 0, 0);
  }
  else if (state==5) {
    image(state5, 0, 0);
  }
  else if (state==6) {
    image(state6, 0, 0);
    //draws highlights over active activities
    for (int i=0; i<=10; i++) {
      if (activityNumber[i]==true) {
        image(highlightSelection, 54, 122+47*i);
      }
    }
  }
  else if (state==7) {
    image(state7, 0, 0);
    //draws highlights over active moods
    for (int i=0; i<=10; i++) {
      if (moodNumber[i]==true) {
        image(highlightSelection, 54, 122+47*i);
      }
    }
  }
  else if (state==8) {
    image(state6, 0, 0);
    //draw moodConfirm window
    for (int i=0; i<=10; i++) {
      if (activityNumber[i]==true) {
        image(highlightSelection, 54, 122+47*i);
      }
    }
    image(inputMood, 82, 151);
    if (confirmSelection==1) {
      image(startPressed, 124, 228);
    }
    if (confirmSelection==2) {
      image(instantPressed, 124, 301);
    }
    if (confirmSelection==4) {
      image(iFeltThisPressed, 124, 390);
    }
    pushStyle();
    fill(143, 255, 201);
    text(activityString[selectedActivity], 240, 202);
    popStyle();
  }
  else if (state==9) {
    //draw activityConfirm window 82, 196
    image(state7, 0, 0);
    for (int i=0; i<=10; i++) {
      if (moodNumber[i]==true) {
        image(highlightSelection, 54, 122+47*i);
      }
    }
    image(inputActivity, 82, 151);
    if (confirmSelection==1) {
      image(startPressed, 124, 228);
    }
    if (confirmSelection==2) {
      image(instantPressed, 124, 301);
    }
    if (confirmSelection==3) {
      image(iDidThisPressed, 124, 390);
    }
    pushStyle();
    fill(143, 255, 201);
    text(moodString[selectedMood], 240, 202);
    popStyle();
  }
  if (state!=0&&state!=1) {
    getThatData();
  }
  
  //Test Elegido
//  String testElegido = toString(elegido);
//  fill(255,0,0);
//  text(String.valueOf(elegido), displayWidth/2, displayHeight-100);
  
}

//-----------INTERACTION-------------//

void mousePressed() {
  //println("mouse pressed");
  if (state!=0&&state!=1) {
    //annotate button location
    if (mouseX>=0&&mouseX<=115&&mouseY>=735&&mouseY<=800) {
      state=2;
    }
    if (mouseX>=122&&mouseX<=234&&mouseY>=735&&mouseY<=800) {
      state=3;
    }
    if (mouseX>=242&&mouseX<=353&&mouseY>=735&&mouseY<=800) {
      state=4;
    }
    if (mouseX>=362&&mouseX<=480&&mouseY>=735&&mouseY<=800) {
      state=5;
    }
  }

  //  if (state==6||state==7&&mouseY<725) {
  //    //test write to SD
  //
  //    //calculate current date and time
  //    msTime = System.currentTimeMillis();
  //    Date curDateTime = new Date(msTime); 
  //    String formattedDateString = formatterDate.format(curDateTime);
  //    String formattedTimeString = formatterTime.format(curDateTime);
  //    
  //    appendToFile(filePath, data+","+formattedDateString+","+formattedTimeString);
  //    
  //    println("SD appended");
  //  }

  if (state==8) {
    if (mouseX<87||mouseX>396||mouseY<152||mouseY>641) {
      state=6;
    }
    if (mouseX>124&&mouseX<353&&mouseY>228&&mouseY<290) {
      confirmSelection=1;
    }
    if (mouseX>124&&mouseX<353&&mouseY>303&&mouseY<362) {
      confirmSelection=2;
    }
    //I DID THIS.. implement later
    //      if (mouseX>87&&mouseX<396&&mouseY>198&&mouseY<641) {
    //        confirmSelection=3;
    //      }
    if (mouseX>160&&mouseX<320&&mouseY>579&&mouseY<620) {
      if (confirmSelection==1) {
        activityNumber[selectedActivity]=!activityNumber[selectedActivity];
        confirmSelection=0;
        state=6;
      }
      if (confirmSelection==2) {
        //get time and write string to SD
        //    //calculate current date and time
        msTime = System.currentTimeMillis();
        Date curDateTime = new Date(msTime); 
        String formattedDateString = formatterDate.format(curDateTime);
        String formattedTimeString = formatterTime.format(curDateTime);
        appendToFile(filePath, formattedDateString+","+formattedTimeString+",1,"+selectedActivity);
        //println("SD appended w/ instant activity:" + formattedDateString+","+formattedTimeString+",1,"+selectedActivity);
        confirmSelection=0;
        state=6;
      }
      //      if(confirmedSelection==3){
      //        enter activity with retroactive time/date
      //      }
    }
  }

  if (state==9) {
    if (mouseX<87||mouseX>396||mouseY<152||mouseY>641) {
      state=7;
    }
    if (mouseX>124&&mouseX<353&&mouseY>228&&mouseY<290) {
      confirmSelection=1;
    }
    if (mouseX>124&&mouseX<353&&mouseY>303&&mouseY<362) {
      confirmSelection=2;
    }
    //I FELT THIS.. implement later
    //      if (mouseX>87&&mouseX<396&&mouseY>198&&mouseY<641) {
    //        confirmSelection=4;
    //      }
    if (mouseX>160&&mouseX<320&&mouseY>579&&mouseY<620) {
      if (confirmSelection==1) {
        moodNumber[selectedMood]=!moodNumber[selectedMood];
        confirmSelection=0;
        state=7;
      }
      if (confirmSelection==2) {
        //get time and write string to SD
        //    //calculate current date and time
        msTime = System.currentTimeMillis();
        Date curDateTime = new Date(msTime); 
        String formattedDateString = formatterDate.format(curDateTime);
        String formattedTimeString = formatterTime.format(curDateTime);
        appendToFile(filePath, formattedDateString+","+formattedTimeString+",2,"+selectedMood);
        //println("SD appended w/ instant mood:" + formattedDateString+","+formattedTimeString+",2,"+selectedMood);
        confirmSelection=0;    
        state=7;
      }
      //      if(confirmedSelection==3){
      //        enter mood with retroactive time/date
      //      }
    }
  }

  if (state==6) {
    for (int i = 0; i <= 9; i++) {
      if (mouseX>=40&&mouseX<=440&&mouseY>=115+(47*i)&&mouseY<157+((47*i))) {  //napping
        state = 8;
        selectedActivity = i;
      }
    }
    //if statement for if custom text field is clicked or box is clicked
    //save for later
  }

  if (state==7) {

    //for loop to check which activity is pressed (not including custom)
    for (int i = 0; i <= 9; i++) {
      if (mouseX>=40&&mouseX<=440&&mouseY>=115+(47*i)&&mouseY<157+((47*i))) {  //napping
        state = 9;
        selectedMood = i;
      }
    }
    //if statement for if custom text field is clicked or box is clicked
    //save for later
  }

  //Once past start and BT selection... will always have the four bottom tabs to navigate

  //specifics of state2
  if (state==2) {
    if (mouseX>=60&&mouseX<=422&&mouseY>=550&&mouseY<=620) {
      state=6;
    }
    if (mouseX>=60&&mouseX<=422&&mouseY>=638&&mouseY<=710) {
      state=7;
    }
  }
  if (state==1) { //this won't exit once we have the bluetooth chech
    switch(estado)
    {
    case 0:
      /*
      if(registrado)
       {
       adaptador.cancelDiscovery();
       }
       */
      break;
    case 1:
      compruebaEleccion();
      break;
    }
  }
  if (state==0) {
    state=1;
  }
}

//----------------------------------------------------------------------------------------------------//

void updateData() {
}

//taken from https://forum.processing.org/topic/log-data-on-a-csv-file-is-it-possible
void appendToFile(String filePath, String data) {
  PrintWriter pw = null;
  try {
    pw = new PrintWriter(new BufferedWriter(new FileWriter(filePath, true))); // true means: "append"
    pw.println(data);
  }
  catch(IOException e) {
    //report problem or handle it
    e.printStackTrace();
  }
  finally {
    if (pw!=null) {
      pw.close();
    }
  }
}

//---------------------Spanish BT functions------------------

void empieza()
{
  dispositivos = new ArrayList();
  /*
    registerReceiver(receptor, new IntentFilter(BluetoothDevice.ACTION_FOUND));
   registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED));
   registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));
   registrado = true;
   adaptador.startDiscovery();
   */
  for (BluetoothDevice dispositivo : adaptador.getBondedDevices())
  {
    dispositivos.add(dispositivo);
  }
  estado = 1;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void listaDispositivos(String texto, color c)
{
  background(0);
  //  textFont(f1);
  fill(c);
  text(texto, displayWidth/2, displayHeight/2);
  if (dispositivos != null)
  {
    for (int indice = 0; indice < dispositivos.size(); indice++)
    {
      BluetoothDevice dispositivo = (BluetoothDevice) dispositivos.get(indice);
      fill(255, 255, 0);
      int posicion = 50 + (indice * 55);
      if (dispositivo.getName() != null)
      {
        text(dispositivo.getName(), displayWidth/2, displayHeight/2 + posicion);
      }
      fill(180, 180, 255);
      text(dispositivo.getAddress(), displayWidth/2, displayHeight/2 + posicion + 20);
      fill(255);
      line(0, posicion + 30, 319, posicion + 30);
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void compruebaEleccion()
{
  //int elegido = ((mouseY - displayHeight/2)-50) / 55;
  elegido = ((mouseY - displayHeight/2)-50) / 55;
  if (elegido < dispositivos.size())   
  {     
    dispositivo = (BluetoothDevice) dispositivos.get(elegido);     
    //println(dispositivo.getName());     
    estado = 2;
  }
} 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void conectaDispositivo() 
{   
  try   
  {     
    socket = dispositivo.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
    /*     
     Method m = dispositivo.getClass().getMethod("createRfcommSocket", new Class[] { int.class });     
     socket = (BluetoothSocket) m.invoke(dispositivo, 1);             
     */
    socket.connect();     
    ins = socket.getInputStream();     
    ons = socket.getOutputStream();     
    estado = 3;
  }   
  catch(Exception ex)   
  {     
    estado = 4;     
    error = ex.toString();     
    //println(error);
  }
}
//////////////////////
void onStart()
{
  super.onStart();
  //println("onStart");
  adaptador = BluetoothAdapter.getDefaultAdapter();
  if (adaptador != null)
  {
    if (!adaptador.isEnabled())
    {
      Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    }
    else
    {
      empieza();
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onStop()
{
  //println("onStop");
  /*
  if(registrado)
   {
   unregisterReceiver(receptor);
   }
   */

  if (socket != null)
  {
    try
    {
      socket.close();
    }
    catch(IOException ex)
    {
      //println(ex);
    }
  }
  super.onStop();
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onActivityResult (int requestCode, int resultCode, Intent data)
{
  //println("onActivityResult");
  if (resultCode == RESULT_OK)
  {
    //println("RESULT_OK");
    empieza();
  }
  else
  {
    //println("RESULT_CANCELED");
    estado = 4;
    error = "No se ha activado el bluetooth";
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public static String readItem(InputStream in) throws IOException
{
  // first, read the total length on 4 bytes
  //  - if first byte is missing, end of stream reached
  int lengthOfString = in.read(); // 1 byte
  //  if (lengthOfString<0) throw new IOException("end of stream");
  //  //  - the other 3 bytes of length are mandatory
  //  for (int i=1;i<4;i++) // need 3 more bytes:
  //  {
  //    int n = in.read();
  //    if (n<0) throw new IOException("partial data");
  //    lengthOfString |= n << (i<<3); // shift by 8,16,24
  //  }
  //Create the array to receive len bytes:
  byte[] EEGString = new byte[lengthOfString];
  // Read the len bytes into the created array
  int offset = 0;
  while (lengthOfString>0) // while there is some byte to read
  {
    int n = in.read(EEGString, offset, lengthOfString); // number of bytes actually read
    if (n<0) throw new IOException("partial data");
    offset += n; // update offset
    lengthOfString -= n; // update remaining number of bytes to read
  }
  // Transform bytes into String item:
  return new String(EEGString);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void muestraError()
{
  background(255, 0, 0);
  fill(255, 255, 0);
  //textFont(f2);
  textAlign(CENTER);
  translate(width / 2, height / 2);
  rotate(3 * PI / 2);
  text(error, 0, 0);
}
//////////////

void getThatData() {
  try
  {     
    while (ins.available () > 0)
    {
      incomingData = readItem(ins);
      //println("incoming data: " + incomingData);
      tempEEG = tempEEG + incomingData;
      String[] arrayTempEEG = split(tempEEG, "$");
      EEGToSD = arrayTempEEG[0];
      tempEEG = tempEEG.replace(arrayTempEEG[0]+"$", "");
      arrayTempEEG[0] = arrayTempEEG[1];
      //println(EEGToSD);

      //Write to SD!!!
      msTime = System.currentTimeMillis();
      Date curDateTime = new Date(msTime); 
      String formattedDateString = formatterDate.format(curDateTime);
      String formattedTimeString = formatterTime.format(curDateTime);
      //write EEG data
      appendToFile(filePath, formattedDateString+","+formattedTimeString+",0,"+EEGToSD);
      fill(0);
      pushStyle();
      textFont(f2);
      if (EEGToSD.length()<=100) {
        text(EEGToSD, 240, 64);
      }
      else{
        text("Signal Error", 240, 64);
      }
      popStyle();
      //println("SD appended");

      //write active activities and moods
      for (int i = 0; i<numActivities;i++) {
        if (activityNumber[i]==true) {
          appendToFile(filePath, formattedDateString+","+formattedTimeString+",1,"+i);
          //println("activity [" + i + "] added to SD");
        }
      }
      for (int i = 0; i<numMoods;i++) {
        if (moodNumber[i]==true) {
          appendToFile(filePath, formattedDateString+","+formattedTimeString+",2,"+i);
          //println("mood [" + i + "] added to SD");
        }
      }
      break;
    }
  }
  catch(Exception ex)
  {
    estado = 4;
    error = ex.toString();
    //println(error);
  }
}

