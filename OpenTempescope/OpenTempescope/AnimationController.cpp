/*
  AnimationController.cpp - Class controlling weather animations on an OpenTempescope
  Released as part of the OpenTempescope project - http://tempescope.com/opentempescope/
  Copyright (c) 2013 Ken Kawamoto.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "AnimationController.h"

AnimationController::AnimationController(){
  _numFrames=0;
  _frames=NULL;
  _isRunning=false;
  _tFrameStart=0;
  _durTotal=0;
}

//doesn't really matter how many times you call this, resets the animation every time.
void AnimationController::start(){
  _isRunning=true;
  _tFrameStart=millis();
  _idxFrame=0;
}
Weather AnimationController::getCurrentWeather(){
  //move animation up to current time
  long tNow=millis();
  long tSinceFrameStart=tNow-_tFrameStart;
  
//    Serial.print(_frames[_idxFrame].duration);
//    Serial.print(" ");
//    Serial.print(tSinceFrameStart);
//    Serial.print(" ");
//    Serial.println(_durTotal);
    
//  Serial.println("=========== starting");
  if(_numFrames==0)
    return Weather(0,kClear,0);
  if(_durTotal==0)
    return _frames[0].weather;
    
    
   while(tSinceFrameStart>0){
//      Serial.print(_idxFrame);
//      Serial.print(" ");
//      Serial.print(_numFrames);
//      Serial.print(" ");
//      Serial.print(tSinceFrameStart);
//      Serial.print(" ");
//      Serial.print(_frames[_idxFrame].duration);
//      Serial.print(" ");
//      Serial.println();
      if(_frames[_idxFrame].duration>tSinceFrameStart){
        tSinceFrameStart=0; //we exit the loop, still in the same animation unit
      }
      else{
        tSinceFrameStart-=_frames[_idxFrame].duration;
        _tFrameStart=tNow-tSinceFrameStart;
        
        _idxFrame++;
        if(_idxFrame==_numFrames) //loop back
          _idxFrame=0;
      }
    }
    
  AnimationFrame *currentFrame=&(_frames[_idxFrame]);
  AnimationFrame *nextFrame= (_idxFrame+1==_numFrames) ? NULL: &(_frames[_idxFrame+1]);
  float pInFrame=(tNow-_tFrameStart)/(float)currentFrame->duration;
  
//  Serial.print(_idxFrame);
//  Serial.print(" ");
//  Serial.print(tNow-_tFrameStart);
//  Serial.print(" ");
//  Serial.print(_frames[_idxFrame].duration);
//  Serial.print(" ");
//  Serial.println(pInFrame);
  Weather retWeather(
    nextFrame==NULL? currentFrame->weather.pNoon() : ((1-pInFrame)*currentFrame->weather.pNoon()+pInFrame*nextFrame->weather.pNoon()) ,
    currentFrame->weather.weatherType(),
    currentFrame->weather.lightning() );
    return retWeather;
}

void AnimationController::setNumFrames(int numFrames){
//  if(this->_numFrames<numFrames){ //do we need to expand our buffer?
//    if(this->_frames!=NULL)
//      free(this->_frames);
//    this->_frames=(AnimationFrame*)calloc(numFrames,sizeof(AnimationFrame));
//  }
  if(this->_frames!=NULL)
      free(this->_frames);
//      Serial.println("callocing");
    this->_frames=(AnimationFrame*)malloc(numFrames*sizeof(AnimationFrame));
    for(int i=0;i<numFrames;i++){
      this->_frames[i].duration=0;
      this->_frames[i].weather=Weather(0,kClear,false);
    }
//    Serial.print("calloc: ");
//    Serial.println((int)(this->_frames));
  this->_numFrames=numFrames;
  _durTotal=0;
  //reset pointers
  start();
  
}
void AnimationController::setFrameAt(int idx, long dur, Weather weather){
  if(idx<_numFrames){
    _durTotal+=(dur- this->_frames[idx].duration);
    this->_frames[idx].duration=dur;
    this->_frames[idx].weather.setFrom(weather);
  }
}

