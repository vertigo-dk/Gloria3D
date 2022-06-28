#pragma once

#include "ofMain.h"
#include "ofxMadOscQuery.h"
#include "ofxGui.h"

class ofApp : public ofBaseApp
{

public:
	void setup();
	void update();
	void draw();
	void exit();

	void keyPressed(int key);
	void keyReleased(int key);
	void mouseMoved(int x, int y);
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void mouseEntered(int x, int y);
	void mouseExited(int x, int y);
	void windowResized(int w, int h);
	void dragEvent(ofDragInfo dragInfo);
	void gotMessage(ofMessage msg);

	void onSyncAB();
	void onSyncBA();

	ofxMadOscQuery madOscQuery;

	ofJson namingJson;

	ofxPanel gui;
	ofxButton syncAtoB; //{"A->B"};
	ofxButton syncBtoA; //{"B->A"};
	ofParameterGroup settings;
	ofParameter<float> offsetAB_X{"offset_AB_X", 1000.0f, -10000.0f, 10000.0f};
	ofParameter<float> offsetAB_Y{"offset_AB_Y", 0.0f, -10000.0f, 10000.0f};
};
