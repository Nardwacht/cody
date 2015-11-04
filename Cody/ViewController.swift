//
//  ViewController.swift
//  Cody
//
//  Created by Mick Wonnink on 10/16/15.
//  Copyright © 2015 nami. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    
    //ui elements
    @IBOutlet weak var codyView: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var tbCode: UITextField!
    @IBOutlet weak var ACbutton: UIButton!
    @IBOutlet weak var CodyTekst: UILabel!
    
    
    
    //local variables
    var commands = [String]()
    var knownCommands = [Command]()
    var secondAction : Bool = false
    var hasGreated : Bool = false
    var defurl : String = ""
    var usedCode : String = ""
    var secondlastCommand : String = "start"
    var failcount : Int = 0
    var lastfaulty : String = "none"
    var myTimer1 : NSTimer = NSTimer()
    var myTimer2 : NSTimer = NSTimer()
    var myTimer3 : NSTimer = NSTimer()
    var myTimer4 : NSTimer = NSTimer()
    var enteredcode : Int = 0

    @IBAction func Opnieuwbtn(sender: AnyObject) {
        BackToMain()
    }
    //function for loading the JSON file from main cody website
    func loadJsonData(url_:String)
    {
        let url = NSURL(string: url_)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            do // TRY for each json object to parse it into a 'command'
            {
                if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, 	   options: NSJSONReadingOptions.AllowFragments)
                {
                    self.parseJsonData(jsonObject)
                }
            }
            catch
            {
                print("Error parsing JSON data")
            }
        }
        dataTask.resume();
    }
    
    //parses the json data into a string array 'commands'
    func parseJsonData(jsonObject:AnyObject)
    {
        if let jsonData = jsonObject as? NSArray
        {
            for item in jsonData
            {
                //recognize commands with the key 'commandname'
                let newCommand = item.objectForKey("commando") as! String
                commands.append(newCommand); //add them to commands list
            }
        }
    }
    
    func CorrectInitialize(){
        print("timer")
    }
    
    //checks the validity of an entered code
    //parameter is a timer because parsing the json data costs time so this method is to be executed after finishing parsing
    func CheckCodeValidity(timer : NSTimer) {
        
        if  (commands.count > 0){
            //data succesfully loaded
            usedCode = commands[0]
            lblInfo.text = "Verbonden met code '" + String(enteredcode) + "'"
            tbCode.hidden = true
            ACbutton.hidden = true;
            secondAction = true
            myTimer4 = NSTimer.scheduledTimerWithTimeInterval(2.1, target: self, selector: Selector("AutoreloadCommandos:"), userInfo: nil, repeats: true)
            
        }
        else{
            //data not found
            lblInfo.text = "Kon geen verbinding maken"
            
        }

    }
    
    func BackToMain(){
        //reset
        myTimer1.invalidate()
        myTimer2.invalidate()
        myTimer3.invalidate()
        myTimer4.invalidate()
        
        codyView.image = UIImage.gifWithName("cody-idle")
        secondAction = false
        hasGreated = false
        defurl = ""
        usedCode = ""
        secondlastCommand = "start"
        failcount = 0
        lastfaulty = "none"
        commands.removeAll()
        tbCode.hidden = false;
        ACbutton.setTitle("Check", forState:UIControlState.Normal)
        lblInfo.text = "Krijg een nieuwe code op Cody.gq"
        ACbutton.hidden = false;
        
        
    }
    
    
    //Checks if the command exists
    func VoerCommandoUit(timer : NSTimer){
        //boolean foundone is to check if there is any command known with the last entered command.
        var foundOne : Bool = false
        
        if (commands.count > 0){
            let lastcmd : String = commands[commands.count-1]
            if (secondlastCommand == lastcmd) {
                codyView.image = UIImage.gifWithName("cody-idle")
                foundOne = true;
            }
            else{
                for cmd in knownCommands
                {
                    if (lastcmd == cmd.command){
                        secondlastCommand = lastcmd;
                        ShowGif(cmd.gifname)
                        foundOne = true
                    }
                }
            }

        }
        let lastcmdt : String = commands[commands.count-1]
        print("~ "+lastcmdt)
        //if there is no command show the 'i don't know this command'.
        if (commands.count == 1){
            if (hasGreated == false) {
            CodyTekst.text = "Hoi " + commands[0] + "!"
                    myTimer1 = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("DisableTekst:"), userInfo: nil, repeats: false)
            ShowGif("cody-talking")
                hasGreated = true
            }
            else{
                codyView.image = UIImage.gifWithName("cody-idle")
            }
        }
        else if (foundOne == false){
            print(secondlastCommand)
            if (secondlastCommand == "cody-vraagteken" + String(failcount)) {
                if (lastfaulty == commands[commands.count-1]){
                codyView.image = UIImage.gifWithName("cody-idle")
                }
                else{
                    lastfaulty = commands[commands.count-1]
                    failcount++;
                    secondlastCommand = "cody-vraagteken" + String(failcount)
                    ShowGif("cody-vraagteken")
                }
            }
            else{
                lastfaulty = commands[commands.count-1]
                failcount++;
                secondlastCommand = "cody-vraagteken" + String(failcount)
                ShowGif("cody-vraagteken")
            }
            
        }
    }
    
    func DisableTekst(timer : NSTimer){
        CodyTekst.text = ""
    }
    
    func AutoreloadCommandos(timer : NSTimer){
        commands.removeAll()
        self.loadJsonData(defurl)
        //executes the command after finishing parsing.
        myTimer2 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("VoerCommandoUit:"), userInfo: nil, repeats: false)
    }
    
    //Shows the .gif with the given name
    func ShowGif(gifname : String){
        codyView.image = UIImage.gifWithName(gifname)
        
    }
    
    //event occurs when the user presses the only button in the view
    //the button changes functionallity after a succesfull initialization
    //the first use is for creating the url with the entered code,
    //the second use is to clear the commands and load the newly entered ones.
    @IBAction func PressBtn(sender: AnyObject) {
        if (secondAction == false){
            if (tbCode.text?.isEmpty == false){
            //TODO Check code.
            var urlstring: String = "http://www.blue90.nl/nard/cody/json/" //http://i329453.iris.fhict.nl/sm32/json/"
                let txt : String = tbCode.text!
            urlstring += tbCode.text!
                enteredcode = Int(txt)!
            urlstring += ".json"
            defurl = urlstring
                self.loadJsonData(defurl)
                //checks the validity of the url after finishing parsing.
                myTimer3 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("CheckCodeValidity:"), userInfo: nil, repeats: false)
              
            }
        }
            /*
        else{
            /*
            commands.removeAll()
            self.loadJsonData(defurl)
            //executes the command after finishing parsing.
            let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("VoerCommandoUit:"), userInfo: nil, repeats: false)
*/
            ACbutton.setTitle("Started", forState:UIControlState.Normal)
            
            
        }
*/
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add all known commands in the initialization of the app.
        knownCommands.append(Command(gifname: "cody-slaap", command: "Cody.Slaap()"))
        knownCommands.append(Command(gifname: "cody-talking", command: "Cody.Praat()"))
        knownCommands.append(Command(gifname: "cody-skateboard", command: "Cody.Skateboard()"))
        
        
        // set the default gif to play when starting the app.
        codyView.image = UIImage.gifWithName("cody-idle")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }

    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

