#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup()
{
    namingJson = ofLoadJson("surfaceNames.json");

    madOscQuery.setup("127.0.0.1", 9001, 8984);

    // ofSetFps(15);

    syncAtoB.addListener(this, &ofApp::onSyncAB);
    syncBtoA.addListener(this, &ofApp::onSyncBA);

    gui.setup("sync");
    gui.add(syncAtoB.setup("A->B"));
    gui.add(syncBtoA.setup("B->A"));
    settings.add(offsetAB_X);
    settings.add(offsetAB_Y);
    gui.add(settings);
}

//--------------------------------------------------------------
void ofApp::onSyncAB()
{
    madOscQuery.madMapperJson.clear();
    madOscQuery.receive();
    ofSleepMillis(100);

    if (madOscQuery.madMapperJson == nullptr)
    {
        ofLog(OF_LOG_WARNING) << "Load unsuccessful!" << endl;
    }

    ofJson namingList = namingJson["nameList"];
    for (auto &it : namingList)
    {
        string nameA = namingJson["groupA_tag"].get<string>() + it.get<string>();
        string nameB = namingJson["groupB_tag"].get<string>() + it.get<string>();
        cout << nameA << " " << nameB << endl;
        ofJson surfaceOutput = madOscQuery.madMapperJson["CONTENTS"]["surfaces"]["CONTENTS"][nameA.c_str()]["CONTENTS"]["output"]["CONTENTS"];
        cout << surfaceOutput << endl;
        madOscQuery.madMapperJson.clear();
        madOscQuery.receive();
        ofSleepMillis(100);

        if (madOscQuery.madMapperJson == nullptr)
        {
            ofLog(OF_LOG_WARNING) << "Load unsuccessful!" << endl;
        }

        ofJson namingList = namingJson["nameList"];
        for (auto &it : namingList)
        {
            string nameA = namingJson["groupA_tag"].get<string>() + it.get<string>();
            string nameB = namingJson["groupB_tag"].get<string>() + it.get<string>();

            ofJson surfaceOutput = madOscQuery.madMapperJson["CONTENTS"]["surfaces"]["CONTENTS"][nameA.c_str()]["CONTENTS"]["output"]["CONTENTS"];

            if (surfaceOutput == nullptr)
            {
                ofLog(OF_LOG_WARNING) << "missing expected surfaces" << endl;
                continue;
            }

            for (int i = 0; i < 4; i++)
            {
                string index = ofToString(i);
                float x = surfaceOutput["handles"]["CONTENTS"][index.c_str()]["CONTENTS"]["x"]["VALUE"][0].get<float>();
                float y = surfaceOutput["handles"]["CONTENTS"][index.c_str()]["CONTENTS"]["y"]["VALUE"][0].get<float>();

                cout << index << " x: " << x << endl;
                cout << index << " y: " << y << endl;

                x += offsetAB_X;
                y += offsetAB_Y;

                ofxOscMessage msg;

                string address = "/surfaces/" + nameB + "/output/handles/" + index;
                cout << address << endl;

                msg.setAddress(address + "/x");
                msg.addFloatArg(x);
                madOscQuery.oscSendToMadMapper(msg);
                msg.clear();
                msg.setAddress(address + "/y");
                msg.addFloatArg(y);
                madOscQuery.oscSendToMadMapper(msg);
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::onSyncBA()
{

    madOscQuery.madMapperJson.clear();
    madOscQuery.receive();
    ofSleepMillis(100);

    if (madOscQuery.madMapperJson == nullptr)
    {
        ofLog(OF_LOG_WARNING) << "Load unsuccessful!" << endl;
    }

    ofJson namingList = namingJson["nameList"];
    for (auto &it : namingList)
    {
        string nameA = namingJson["groupA_tag"].get<string>() + it.get<string>();
        string nameB = namingJson["groupB_tag"].get<string>() + it.get<string>();
        cout << nameA << " " << nameB << endl;
        ofJson surfaceOutput = madOscQuery.madMapperJson["CONTENTS"]["surfaces"]["CONTENTS"][nameA.c_str()]["CONTENTS"]["output"]["CONTENTS"];
        cout << surfaceOutput << endl;
        madOscQuery.madMapperJson.clear();
        madOscQuery.receive();
        ofSleepMillis(100);

        if (madOscQuery.madMapperJson == nullptr)
        {
            ofLog(OF_LOG_WARNING) << "Load unsuccessful!" << endl;
        }

        ofJson namingList = namingJson["nameList"];
        for (auto &it : namingList)
        {
            string nameA = namingJson["groupA_tag"].get<string>() + it.get<string>();
            string nameB = namingJson["groupB_tag"].get<string>() + it.get<string>();

            ofJson surfaceOutput = madOscQuery.madMapperJson["CONTENTS"]["surfaces"]["CONTENTS"][nameB.c_str()]["CONTENTS"]["output"]["CONTENTS"];

            if (surfaceOutput == nullptr)
            {
                ofLog(OF_LOG_WARNING) << "missing expected surfaces" << endl;
                continue;
            }

            for (int i = 0; i < 4; i++)
            {
                string index = ofToString(i);
                float x = surfaceOutput["handles"]["CONTENTS"][index.c_str()]["CONTENTS"]["x"]["VALUE"][0].get<float>();
                float y = surfaceOutput["handles"]["CONTENTS"][index.c_str()]["CONTENTS"]["y"]["VALUE"][0].get<float>();

                cout << index << " x: " << x << endl;
                cout << index << " y: " << y << endl;

                x -= offsetAB_X;
                y -= offsetAB_Y;

                ofxOscMessage msg;

                string address = "/surfaces/" + nameA + "/output/handles/" + index;
                cout << address << endl;

                msg.setAddress(address + "/x");
                msg.addFloatArg(x);
                madOscQuery.oscSendToMadMapper(msg);
                msg.clear();
                msg.setAddress(address + "/y");
                msg.addFloatArg(y);
                madOscQuery.oscSendToMadMapper(msg);
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::exit()
{
    syncAtoB.removeListener(this, &ofApp::onSyncAB);
    syncBtoA.removeListener(this, &ofApp::onSyncBA);
}

//--------------------------------------------------------------
void ofApp::update()
{
}

//--------------------------------------------------------------
void ofApp::draw()
{
    gui.draw();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key)
{
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key)
{
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button)
{
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y)
{
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h)
{
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg)
{
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo)
{
}
