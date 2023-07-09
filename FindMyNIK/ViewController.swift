//
//  ViewController.swift
//  FindMyNIK
//
//  Created by Dimas Wisodewo on 09/07/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topContainerView: UIView!
    
    @IBOutlet weak var cardBaseView: UIView! {
        didSet {
            cardBaseView.clipsToBounds = true
            cardBaseView.roundCorners(
                corners: [.topLeft,
                          .topRight,
                          .bottomLeft,
                          .bottomRight],
                radius: 24)
        }
    }
    
    @IBOutlet weak var nikContainerView: UIStackView!
    
    @IBOutlet weak var nikLabel: UILabel!
    
    @IBOutlet weak var provinsiTextField: UITextField! {
        didSet {
            provinsiTextField.inputView = pickerView
            provinsiTextField.addTarget(self, action: #selector(selectProvinsiTextField), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var kabupatenTextField: UITextField! {
        didSet {
            kabupatenTextField.inputView = pickerView
            kabupatenTextField.addTarget(self, action: #selector(selectKabupatenTextField), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var kecamatanTextField: UITextField! {
        didSet {
            kecamatanTextField.inputView = pickerView
            kecamatanTextField.addTarget(self, action: #selector(selectKecamatanTextField), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var designCreditButton: UIButton! {
        didSet {
            designCreditButton.addTarget(
                self,
                action: #selector(designCreditButtonPressed),
                for: .touchUpInside)
        }
    }
    
    private var selectedTextField: UITextField?
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker.backgroundColor = UIColor.white
        return picker
    }()
    
    private var provinsiArray: [Provinsi] = [Provinsi]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        addTopViewGradient()
        addCardGradient()
        
        loadDataWilayah()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Open design credit
    @objc private func designCreditButtonPressed() {
        guard let url = URL(string: "https://dribbble.com/shots/16648936-Cardy-Custom-Credit-Cards") else { return }
        
        UIApplication.shared.open(url)
    }
    
    private func loadDataWilayah() {
        guard let jsonData = JsonUtils.shared.readLocalJSONFile(forName: "kode_wilayah") else {
            print("Error reading local JSON file")
            return
        }
        
        provinsiArray = JsonUtils.shared.parse(jsonData: jsonData)
        print("provinsiArray count: \(provinsiArray.count)")
    }
    
    @objc private func selectProvinsiTextField() {
        print("Provinsi")
        selectedTextField = provinsiTextField
    }
    
    @objc private func selectKabupatenTextField() {
        print("Kabupaten")
        selectedTextField = kabupatenTextField
    }
    
    @objc private func selectKecamatanTextField() {
        print("Kecamatan")
        selectedTextField = kecamatanTextField
    }

    private func addCardGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(named: "PrimaryBlue")!
                .withAlphaComponent(0.8).cgColor,
            UIColor(named: "PrimaryBlue")!
                .withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        
        gradientLayer.frame = cardBaseView.bounds
        cardBaseView.layer.addSublayer(gradientLayer)
        
        // Bring card label to front
        nikContainerView.superview?.bringSubviewToFront(nikContainerView)
    }
    
    private func addTopViewGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.08).cgColor,
        ]
        
        gradientLayer.frame = topContainerView.bounds
        topContainerView.layer.addSublayer(gradientLayer)
    }

}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return provinsiArray.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return provinsiArray[row].namaProvinsi
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField?.text = provinsiArray[row].namaProvinsi
    }
    
}

