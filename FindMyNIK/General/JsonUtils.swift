//
//  JsonUtils.swift
//  FindMyNIK
//
//  Created by Dimas Wisodewo on 09/07/23.
//

import Foundation

//struct user: Codable {
//    let userId: Int
//    let firstName: String
//    let lastName: String
//    let phoneNumber: String
//    let emailAddress: String
//}
//struct sampleRecord: Codable {
//    let users: [user]
//}

struct Provinsi: Decodable {
    
    var kodeProvinsi: String = ""
    var namaProvinsi: String = ""
    var kabupaten: [Kabupaten] = []
    
    enum CodingKeys: String, CodingKey {
        case kodeProvinsi = "kode_provinsi"
        case namaProvinsi = "nama_provinsi"
        case kabupaten = "kabupaten"
    }
}

struct Kabupaten: Decodable {
    
    var kodeKabupaten: String = ""
    var namaKabupaten: String = ""
    var kecamatan: [Kecamatan] = []
    
    enum CodingKeys: String, CodingKey {
        case kodeKabupaten = "kode_kabupaten"
        case namaKabupaten = "nama_kabupaten"
        case kecamatan = "kecamatan"
    }
}

struct Kecamatan: Decodable {
    
    var kodeKecamatan: String = ""
    var namaKecamatan: String = ""
    
    enum CodingKeys: String, CodingKey {
        case kodeKecamatan = "kode_kecamatan"
        case namaKecamatan = "nama_kecamatan"
    }
}

class JsonUtils {
    
    static let shared = JsonUtils()
    
    func readLocalJSONFile(forName name: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            } else {
                print("Error 0")
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    func parse(jsonData: Data) -> [Provinsi] {
        do {
            let decodedData = try JSONDecoder().decode([Provinsi].self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return [Provinsi]()
    }
    
}
