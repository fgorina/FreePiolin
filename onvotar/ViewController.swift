//
//  ViewController.swift
//  onvotar
//
//  Created by Francisco Gorina Vanrell on 28/9/17.
//  Copyright © 2017 Francisco Gorina. All rights reserved.
//

import UIKit
import Security
import CryptoSwift
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var fDNI: UITextField!
    
    @IBOutlet weak var fDia: UITextField!
    @IBOutlet weak var fMes: UITextField!
    @IBOutlet weak var fAny: UITextField!
    @IBOutlet weak var fCP: UITextField!
    
    @IBOutlet weak var fResult: UITextView!
    
    var carrer = ""
    var poblacio = ""
    
    let baseUrl : URL = URL(string: "https://ipfs.io/ipns/QmZxWEBJBVkGDGaKdYPQUXX4KC5TCWbvuR4iYZrTML8XCR/db.20170926")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goToMap(){
        
        let geocoder = CLGeocoder()
        let str = carrer + " " + poblacio
        geocoder.geocodeAddressString(str) { (placemarksOptional, error) -> Void in
            if let placemarks = placemarksOptional {
                print("placemark| \(placemarks.first)")
                if let location = placemarks.first?.location {
                    let query = "?daddr=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                    let path = "http://maps.apple.com/" + query
                    if let url = URL(string: path) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (done:Bool) in
                            if !done{
                                NSLog("Not done")
                            }
                        })
                    } else {
                        // Could not construct url. Handle error.
                    }
                } else {
                    // Could not get a location from the geocode request. Handle error.
                }
            } else {
                // Didn't get any placemarks. Handle error.
            }
        }
        
    }
    @IBAction func cercar(){
        
        var dni : String = ""
        var dia : String = ""
        var mes : String = ""
        var ano : String = ""
        var cp : String = ""
        if let dn = fDNI.text{
            dni = String(dn.uppercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").suffix(6))
        }
        
        if let di = fDia.text{
            dia = di.uppercased().replacingOccurrences(of: " ", with: "")
        }
        if let me = fMes.text{
            mes = me.uppercased().replacingOccurrences(of: " ", with: "")
        }
        if let an = fAny.text{
            ano = an.uppercased().replacingOccurrences(of: " ", with: "")
        }
        if let c = fCP.text{
            cp = c.uppercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        }
        
        _ = doResignFirstResponder(self.view)
        
        let key = dni + ano + mes + dia + cp
        if let key_data = key.data(using: .utf8){
            
            let firstHash = doHash(dat: doHashBucle(dat: key_data, count:1714))
            let secondHash = doHash(dat: firstHash)
            
            let str = String(data:secondHash, encoding: .utf8)!
            
            let i1 = str.index(str.startIndex, offsetBy: 2)
            let i2 = str.index(str.startIndex, offsetBy: 4)
            let i3 = str.index(str.startIndex, offsetBy: 64)
            let rn = i1..<i2
            let rncode = i2..<i3
            
            let dirStr = str.substring(to:i1)
            let fileStr = str.substring(with: rn) + ".db"
            
            let code = str.substring(with:rncode)
            
            // TODO : Use the remote database. If there is an error (not clear what it is) use the local one
            
            let localUrl = AppDelegate.localApplicationDocumentsDirectory()!.appendingPathComponent("db").appendingPathComponent(dirStr).appendingPathComponent(fileStr)
            
            let remoteUrl = baseUrl.appendingPathComponent(dirStr).appendingPathComponent(fileStr)
            
            var contingut : Data?
            var islocal = false
            var url = remoteUrl
            
            do{
                contingut = try Data(contentsOf: remoteUrl)
            } catch {
                
                do{
                    url = localUrl
                    contingut = try Data(contentsOf: localUrl)
                    islocal = true
                } catch {
                    fResult.text = "Error al carregar el fitxer "+url.absoluteString
                    return
                }
            }
            
            if let cnt = contingut{
                // Get Data from the file
                if let contents = String(data:cnt, encoding: .utf8){
                    let array = contents.components(separatedBy: "\n")
                    
                    for line in array{
                        if line != ""{
                            let breakIndex = line.index(line.startIndex, offsetBy: 60)
                            let codePart = line.substring(to: breakIndex)
                            
                            if codePart == code{
                                let encrypted = line.substring(from: breakIndex)
                                let decrypted = decrypt(encrypted: encrypted, passwd: firstHash)
                                
                                var text = "Dades remotes actualitzades\n\n"
                                
                                if islocal {
                                    text = "Dades locals. Poden no estar actualitzades\n\n"
                                }
                                fResult.text = text + decrypted
                                
                                // Now update local file with new data as we know it is good
                                if !islocal {
                                    do{
                                        try cnt.write(to: localUrl)
                                    }catch{
                                        
                                    }
                                }
                                return
                            }
                        }
                    }
                    fResult.text = "Dades no disponibles"
                    
                }
            } else {
                fResult.text = "Error al carregar el fitxer "+url.absoluteString
            }
        }
    }
    
    
    func doHashBucle(dat : Data, count: Int) -> Data{  
        var hashed = dat
        
        for _ in 0..<count{
            hashed = doHash(dat: hashed)
        }
        return hashed
    }
    
    func doHash(dat: Data) -> Data{
        let hash = dat.sha256()
        let hexhash = toHex(dat: hash)
        return hexhash
        
    }
    
    func toHex(dat: Data) -> Data{
        var newData = Data()
        
        for x in dat{
            let s = String(format:"%02x", x)
            newData.append(s.data(using: .utf8)!)
            
        }
        return newData
    }
    
    
    func decrypt(encrypted: String, passwd: Data) -> String{
        
        // First we must pass Data a binary (data son hex)
        
        let data = encrypted.hexadecimal()!
        
        // Here we get the key and the iv from the password. It is not the most sure anyway
        
        let returned = ViewController.evpBytesToKey(32, ivLen: 16, digest: "md5", salt:[], data: passwd, count:1)
        let key = returned[0]
        let iv = returned[1]
        
        do{
            
            let aes = try AES(key: key, iv: iv, blockMode:.CBC, padding: .pkcs7)
            let clearbytes = try aes.decrypt(data.bytes)
            let cleardata = Data(bytes: clearbytes)
            
            // Now split with # to get different fields. resposta[6] continues encrypted and I don't know the meaning.
            
            if let clearstr = String(data:cleardata, encoding:.utf8){
                let resposta = clearstr.split(separator: "#")
                let colegi = resposta[0]
                carrer = String(resposta[1])
                poblacio = String(resposta[2])
                let districte = resposta[3]
                let seccio = resposta[4]
                let mesa = resposta[5]
                
                var message = "Has d'anar a votar a:\n\n"+colegi+"\n"+carrer+"\n"+poblacio
                
                message = message + "\n\nDistricte: "+districte+"\nSecció: "+seccio + "\nMesa: "+mesa
                
                return message
            }
        } catch {
            return "Error al desencriptar. Informació no disponible."
        }
        return "Dades corruptes. Informació no disponible."
    }
    
    func doResignFirstResponder(_ view: UIView) -> Bool{
        
        if view.isFirstResponder{
            view.resignFirstResponder()
            return true
        }
        
        for subView in view.subviews{
            if doResignFirstResponder(subView){
                return true
            }
        }
        
        
        
        return false
        
    }
    
    
    
    /*
     
     from Space Monkey
     - parameter keyLen: keyLen
     - parameter ivLen:  ivLen
     - parameter digest: digest e.g "md5" or "sha1"
     - parameter salt:   salt
     - parameter data:   data
     - parameter count:  count
     
     - returns: key and IV respectively
     */
    open static func evpBytesToKey(_ keyLen:Int, ivLen:Int, digest:String, salt:[UInt8], data:Data, count:Int)-> [[UInt8]] {
        let saltData = Data(bytes: UnsafePointer<UInt8>(salt), count: Int(salt.count))
        var both = [[UInt8]](repeating: [UInt8](), count: 2)
        var key = [UInt8](repeating: 0,count: keyLen)
        var key_ix = 0
        var iv = [UInt8](repeating: 0,count: ivLen)
        var iv_ix = 0
        
        var nkey = keyLen;
        var niv = ivLen;
        
        var i = 0
        var addmd = 0
        var md:Data = Data()
        var md_buf:[UInt8]
        
        while true {
            
            addmd = addmd + 1
            md.append(data)
            md.append(saltData)
            
            if(digest=="md5"){
                md = NSData(data:md.md5()) as Data
            }else if (digest == "sha1"){
                md = NSData(data:md.sha1()) as Data
            }
            
            for _ in 1..<(count){
                
                if(digest=="md5"){
                    md = NSData(data:md.md5()) as Data
                }else if (digest == "sha1"){
                    md = NSData(data:md.sha1()) as Data
                }
            }
            md_buf = Array (UnsafeBufferPointer(start: md.bytes, count: md.count))
            //            md_buf = Array(UnsafeBufferPointer(start: md.bytes.bindMemory(to: UInt8.self, capacity: md.count), count: md.length))
            i = 0
            if (nkey > 0) {
                while(true) {
                    if (nkey == 0){
                        break
                    }
                    if (i == md.count){
                        break
                    }
                    key[key_ix] = md_buf[i];
                    key_ix = key_ix + 1
                    nkey = nkey - 1
                    i = i + 1
                }
            }
            if (niv > 0 && i != md_buf.count) {
                while(true) {
                    if (niv == 0){
                        break
                    }
                    if (i == md_buf.count){
                        break
                    }
                    iv[iv_ix] = md_buf[i]
                    iv_ix = iv_ix + 1
                    niv = niv - 1
                    i = i + 1
                }
            }
            if (nkey == 0 && niv == 0) {
                break
            }
            
        }
        both[0] = key
        both[1] = iv
        
        return both
        
    }
}

