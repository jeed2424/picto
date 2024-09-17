//
//  NetworkingConstants.swift
//  picto
//
//  Created by Jay on 2024-09-08.
//

import Foundation

protocol NetworkingConstants {
    var stringValue: String { get }
}

class baseUrlConstant: NetworkingConstants {
    var stringValue: String = "https://lwjdzeppcejfnzqngngf.supabase.co/functions/v1/"
}

class supabaseApiKeyConstant: NetworkingConstants {
    var stringValue: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3amR6ZXBwY2VqZm56cW5nbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQ5MDU0NjUsImV4cCI6MjAxMDQ4MTQ2NX0.5w8RqxMrR-sP7pi6PaCJldbYlUnxLmet1v_Hd6O9wxM"
}
