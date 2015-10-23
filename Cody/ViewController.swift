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
    
    
    
    //local variables
    var commands = [String]()
    var knownCommands = [Command]()
    var secondAction : Bool = false
    var defurl : String = ""
    var usedCode : String = ""

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
    
    //checks the validity of an entered code
    //parameter is a timer because parsing the json data costs time so this method is to be executed after finishing parsing
    func CheckCodeValidity(timer : NSTimer) {
        
        if  (commands.count > 0){
            //data succesfully loaded
            usedCode = commands[0]
            lblInfo.text = "Verbonden met '" + usedCode + "'"
            tbCode.hidden = true
            ACbutton.setTitle("Voer uit", forState:UIControlState.Normal)
            secondAction = true
            
        }
        else{
            //data not found
            lblInfo.text = "Kon geen verbinding maken"
            
        }

    }
    
    
    //Checks if the command exists
    func VoerCommandoUit(timer : NSTimer){
        //boolean foundone is to check if there is any command known with the last entered command.
        var foundOne : Bool = false
        
        if (commands.count > 0){
            let lastcmd : String = commands[commands.count-1]
            for cmd in knownCommands
            {
                if (lastcmd == cmd.command){
                    ShowGif(cmd.gifname)
                    foundOne = true
                }
            }
        }
        
        //if there is no command show the 'i don't know this command'.
        if (foundOne == false){
            ShowGif("cody-vraagteken")
        }
    }
    
    //Shows the .gif with the given name
    func ShowGif(gifname : String){
        codyView.image = UIImage.gifWithName(gifname)
        print("here")
    }
    
    //event occurs when the user presses the only button in the view
    //the button changes functionallity after a succesfull initialization
    //the first use is for creating the url with the entered code,
    //the second use is to clear the commands and load the newly entered ones.
    @IBAction func PressBtn(sender: AnyObject) {
        if (secondAction == false){
            if (tbCode.text?.isEmpty == false){
            //TODO Check code.
            var urlstring: String = "http://i329453.iris.fhict.nl/sm32/json/"
            urlstring += tbCode.text!
            urlstring += ".json"
            defurl = urlstring
                self.loadJsonData(defurl)
                //checks the validity of the url after finishing parsing.
                let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("CheckCodeValidity:"), userInfo: nil, repeats: false)
              
            }
        }
        else{
            commands.removeAll()
            self.loadJsonData(defurl)
            //executes the command after finishing parsing.
            let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("VoerCommandoUit:"), userInfo: nil, repeats: false)
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add all known commands in the initialization of the app.
        knownCommands.append(Command(gifname: "cody-slaap", command: "Cody.Slaap()"))
        knownCommands.append(Command(gifname: "cody-talking", command: "Cody.Praat()"))
        knownCommands.append(Command(gifname: "cody-skateboard", command: "Cody.Skateboard()"))
        
        
        // set the default gif to play when starting the app.
        codyView.image = UIImage.gifWithName("cody-idle")
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
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

