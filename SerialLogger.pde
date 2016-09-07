import controlP5.*;

import processing.serial.*;

Serial mySerial;

String serialStr = "";
PrintWriter output;

ControlP5 cp5;
int bgColor = color(100);
int logAreaColor = color(250);
int ddlColor = color(150);

Textarea serialLogTextarea;
DropdownList portList,baudList;

String selectedPort;
boolean isConnect;

String[] baudRate = {
  "300",
  "1200",
  "2400",
  "4800",
  "9600",
  "14400",
  "19200",
  "28800",
  "38400",
  "57600",
  "115200"
};

int selectedBaud;

void setup(){
  size(640,480);
  noStroke();
  cp5 = new ControlP5(this);
  cp5Init();
  //println(Serial.list());
  //mySerial = new Serial(this, PORT,BAUD);
  //mySerial.clear();

  //output = createWriter("SerialLog_"+nf(year(),2)+nf(month(),2)+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+".log");

  selectedPort = null;
  selectedBaud = -1;
  isConnect = false;
  textPrintln("\"Select Serial Port\"");
}

void draw(){
  serialLoop();
  background(bgColor);
}

String updateDateTime(){
  return nf(year(),2)+"/"+nf(month(),2)+"/"+nf(hour(),2)+":"+nf(minute(),2)+":"+nf(second(),2);
}

void dispose(){
  if(isConnect){
    serialDisconnect();
  }
}

void serialLoop(){
  if(isConnect ){
    if( mySerial.available() > 0){
      delay(100);
      serialStr = mySerial.readString();//文字列更新
      if(serialStr.length() < 40){;
        //print(updateDateTime()+",");
        //println(serialStr);
        if(serialStr.contains("\n")){
          textPrint(updateDateTime()+","+serialStr);
          output.print(updateDateTime()+","+serialStr);
        }else{
          textPrintln(updateDateTime()+","+serialStr);
          output.println(updateDateTime()+","+serialStr);
        }
        //textPrintln(updateDateTime()+","+serialStr);
        //output.println(updateDateTime()+","+serialStr);
        output.flush();
      }
    }
  }
}

void cp5Init(){
  cp5.addButton("connect").setValue(1)
                          .setFont(createFont("arial",16))
                          .setPosition(130,20)
                          .setSize(100,50);
  cp5.addButton("disconnect").setValue(0)
                             .setFont(createFont("arial",15))
                             .setPosition(240,20)
                             .setSize(100,50);
  serialLogTextarea = cp5.addTextarea("serialLog")
                         .setPosition(20,80)
                         .setSize(600,385)
                         .setFont(createFont("arial",15))
                         .setLineHeight(18)
                         .setColor(color(0))
                         .setColorBackground(logAreaColor)
                         .setColorForeground(logAreaColor);
  serialLogTextarea.scroll(1);
  portList = cp5.addDropdownList("portList")
                .setFont(createFont("arial",12))
                .setPosition(20,32)
                .setSize(100,100);
  portListInit(portList);
  baudList = cp5.addDropdownList("baudList")
                .setFont(createFont("arial",12))
                .setPosition(500,32)
                .setSize(100,100);
  baudListInit(baudList);
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
  
  if(theEvent.getController().getName() == ("portList")){
    setPort(theEvent.getController().getValue());
  }
  if(theEvent.getController().getName() == ("baudList")){
    setBaud(theEvent.getController().getValue());
  }
}

public void connect(int theValue){
  serialConnect(selectedBaud,selectedPort);
}

public void disconnect(int theValue){
  serialDisconnect();
}

void serialConnect(int baud,String port){
  if(!isConnect && port != null && baud != -1){
    mySerial = new Serial(this,port,baud);
    mySerial.clear();
    isConnect = true;
    
    output = createWriter("SerialLog_"+nf(year(),2)+nf(month(),2)+nf(day(),2)+"_"+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+".log");
    
    textPrintln("\"Start connection: Port "+port+"\"");
  }
  if(port == null){
    textPrintln("\"Connection error: Select Port!\"");
  }
  if(baud == -1){
    textPrintln("\"Connection error: Select Baud Rate!\"");
  }
}

void serialDisconnect(){
  if(isConnect){
    output.flush();
    output.close();
    textPrintln("\"Output Close\"");
    
    mySerial.stop();
    mySerial = null;
    isConnect = false;
    textPrintln("\"Serial Close\"");
    
  }
}

void portListInit(DropdownList ddl){
  ddl.setItemHeight(20);
  ddl.setBarHeight(25);
  ddl.getCaptionLabel().set("Serial Port");
  
  //todo: addの方法を「addItems」に変更
  for(int i = 0; i < Serial.list().length;i++){
    ddl.addItem(Serial.list()[i],i);
  }
  ddl.setColorBackground(ddlColor);
  ddl.setColorActive(color(0));
}

void baudListInit(DropdownList ddl){
  ddl.setItemHeight(20);
  ddl.setBarHeight(25);
  ddl.getCaptionLabel().set("Baud Rate");
  ddl.addItems(baudRate);
  ddl.setColorBackground(ddlColor);
  ddl.setColorActive(color(0));
}

void setPort(float index){
  selectedPort = portList.getItem(int(index)).get("name").toString();
  textPrintln("\"Set Serial Port → " +selectedPort  +" \"");
}
void setBaud(float index){
  selectedBaud = int(baudList.getItem(int(index)).get("name").toString());
  textPrintln("\"Set Baud Rate → " +selectedBaud +"\"");
}

void textPrint(String str){
  serialLogTextarea.append(str);
  print(str);
}

void textPrintln(String str){
  serialLogTextarea.append(str+"\n");
  print(str+"\n");
}