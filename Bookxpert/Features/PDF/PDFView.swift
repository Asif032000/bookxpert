//
//  PDFView.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFView: View {
    @State private var pdfDoc: PDFDocument?
    let url = URL(string: "https://fssservices.bookxpert.co/GeneratedPDF/Companies/nadc/2024-2025/BalanceSheet.pdf")!
    init(pdfDoc: PDFDocument? = nil) {
        self.pdfDoc = pdfDoc
    }
    var body: some View {
        WebView(url)  
    }
}
