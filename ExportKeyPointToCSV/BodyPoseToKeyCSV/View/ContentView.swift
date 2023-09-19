//
//  ContentView.swift
//  ExportKeyPointToCSV
//
//  Created by Elvin Sestomi on 16/09/23.
//

import SwiftUI
import CSV
import Vision

struct ContentView: View {
    
    @State var folderURL : URL?
    @State var images : [ImagesData] = []
    
    @State var imagesKeyStrokes : [[HumanBodyJoint]] = []

    var visionManager : VisionManager = VisionManager()
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(images, id : \.self) {img in
                    ZStack {
                        GeometryReader { proxy in
                            Image(nsImage: img.image)
                                .resizable	()
                                .scaledToFit()
                                .frame(width: proxy.size.width, height: proxy.size
                                    .height)
                        }.frame(width: 600, height: 200)
                    }
                }
            }
            .frame(height: 600)
            Spacer()
            HStack {
                Button {
                    chooseFolder()
                } label: {
                    Text("Choose folder")
                        .padding(.all, 20)
                        
                }
                .cornerRadius(8)
                .background(.yellow)
                .padding(.trailing, 20)
                
                Button {
                    exportToCSV(data: self.imagesKeyStrokes)
                } label: {
                    Text("Export to CSV")
                        .padding(.all, 20)
                }
                .cornerRadius(8)
                .background(.green)
                
            }
            Spacer();
        }.frame(height: 700)
            .onChange(of: images) { img in
                img.forEach { img in
                    var keypoints : [HumanBodyJoint] = []
                    guard let cgImage = img.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                        print("casting to cgImage failed di bagian content view on appear function dari Vstack terluar")
                        return
                    }
                    visionManager.handlingImage(img: cgImage) { obv, img in
                        let observation = obv.last
                        print("===================\n\n")
                        if let observation = observation {
                            for pointName in HumanBodyJoint.jointNames {
                                do {
                                    let keypoint = try observation.recognizedPoint(pointName)
                                    
                                    let normPoint = VNImagePointForNormalizedPoint(keypoint.location, img.width , img.height)
                                    keypoints.append(HumanBodyJoint(jointName: pointName, xPosition: normPoint.x, yPosition: normPoint.y))
                                    
                                } catch let err {
                                    print("Error di getting  \(pointName.rawValue) with error: \(err.localizedDescription)")
                                }
                            }
                            if keypoints.count == 18{
                                print("keypoints count on this images : \(keypoints.count)")
                                self.imagesKeyStrokes.append(keypoints)
                            } else {
                                print("apakah anda ingin menambahkan observation yang kurang dari 18 Keypoints? ini adalah konstraint dari project, anda bisa mengubah di source code jika anda tetap ingin begitu")
                            }
                        }
                    }
                }
            }
    }
    
    func chooseFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { res in
            if res.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.folderURL = openPanel.url
                
                loadImagesFromSelectedFolder()
            }
        }
    }
    
    func loadImagesFromSelectedFolder() {
        guard let folderUrl = self.folderURL else {
            print("No folder URL yet")
            return
        }
        
        do{
            let content = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: [])
            
            for itemUrl in content {
                let image = NSImage(contentsOf: itemUrl)
                
                if let img = image {
                    self.images.append(ImagesData(image: img))
                }
            }
        } catch let err{
            print("Error : \(err.localizedDescription)")
            return
        }
    }
    
    func exportToCSV(data : [[HumanBodyJoint]]) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = "keypoints"
            let csvUrl = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("csv")
            
            if FileManager.default.createFile(atPath: csvUrl.path, contents: nil, attributes: nil) {
                print("File Created")
                if let outputStream = OutputStream(url: csvUrl, append: false) {
                    // Setting Column Name
                    var columnname : [String] = []
                    HumanBodyJoint.jointNames.forEach { jn in
                        columnname.append("\(jn.rawValue.rawValue)_x")
                        columnname.append("\(jn.rawValue.rawValue)_y")
                    }
                    
                    do {
                        let csv = try CSVWriter(stream: outputStream)
                        
                        // FirstRow || Header
                        try csv.write(row: columnname)
                        
                        // Second Row || First record and so on
                        if imagesKeyStrokes.count > 0 {
                            try self.imagesKeyStrokes.forEach { iks in
                                // kumpulan gambar yang sudah di analisa keystrokes nya
                                var record = [String]()
                                iks.forEach { ks in // Keystroke dari suatu gambar
                                    record.append("\(ks.xPosition)")
                                    record.append("\(ks.yPosition)")
                                }
                                try csv.write(row: record)
                            }
                        }
                        
                    } catch let err{
                        print("Error di bagian writing ke CSV dengan Error : \(err.localizedDescription)")
                    }
                }
            } else {
                print("File tidak ter Create")
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

