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
            cardBaseView.layer.cornerRadius = 24
        }
    }
    
    @IBOutlet weak var nikContainerView: UIStackView!
    
    @IBOutlet weak var nikLabel: UILabel!
    var getNikLabelText: String? {
        get {
            nikLabel.text
        }
    }
    
    @IBOutlet weak var provinsiTextField: TextFieldNoCopyPaste! {
        didSet {
            provinsiTextField.inputView = pickerView
            provinsiTextField.addTarget(self, action: #selector(selectProvinsiTextField), for: .editingDidBegin)
            provinsiTextField.addTarget(self, action: #selector(reloadPickerViewComponents), for: .editingDidEnd)
        }
    }
    
    @IBOutlet weak var kabupatenTextField: TextFieldNoCopyPaste! {
        didSet {
            kabupatenTextField.inputView = pickerView
            kabupatenTextField.isEnabled = false
            kabupatenTextField.addTarget(self, action: #selector(selectKabupatenTextField), for: .editingDidBegin)
            kabupatenTextField.addTarget(self, action: #selector(reloadPickerViewComponents), for: .editingDidEnd)
        }
    }
    
    @IBOutlet weak var kecamatanTextField: TextFieldNoCopyPaste! {
        didSet {
            kecamatanTextField.inputView = pickerView
            kecamatanTextField.isEnabled = false
            kecamatanTextField.addTarget(self, action: #selector(selectKecamatanTextField), for: .editingDidBegin)
            kecamatanTextField.addTarget(self, action: #selector(reloadPickerViewComponents), for: .editingDidEnd)
        }
    }
    
    @IBOutlet weak var genderTextField: TextFieldNoCopyPaste! {
        didSet {
            genderTextField.delegate = self
            genderTextField.inputView = pickerView
            genderTextField.addTarget(self, action: #selector(selectGenderTextField), for: .editingDidBegin)
            genderTextField.addTarget(self, action: #selector(reloadPickerViewComponents), for: .editingDidEnd)
        }
    }
    
    @IBOutlet weak var birthdayTextField: TextFieldNoCopyPaste! {
        didSet {
            birthdayTextField.delegate = self
            birthdayTextField.inputView = datePickerView
        }
    }
    
    @IBOutlet weak var kodeUnikTextField: TextFieldNoCopyPaste! {
        didSet {
            kodeUnikTextField.keyboardType = .numberPad
            kodeUnikTextField.delegate = self
            kodeUnikTextField.addTarget(self, action: #selector(onKodeUnikTextFieldHasChanged), for: .editingChanged)
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
    
    private lazy var provinsiTextRange: Range<String.Index> = {
        let startIndex = nikLabel.text!.startIndex
        let endIndex = nikLabel.text!.index(startIndex, offsetBy: 2)
        return startIndex..<endIndex
    }()
    
    private lazy var kabupatenTextRange: Range<String.Index> = {
        let nikLabelText = getNikLabelText!
        let startIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 3)
        let endIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 5)
        return startIndex..<endIndex
    }()
    
    private lazy var kecamatanTextRange: Range<String.Index> = {
        let nikLabelText = getNikLabelText!
        let startIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 6)
        let endIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 8)
        return startIndex..<endIndex
    }()
    
    private lazy var birthDayTextRange: Range<String.Index> = {
        let nikLabelText = getNikLabelText!
        let startIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 9)
        let endIndex = nikLabelText.index(nikLabelText.startIndex, offsetBy: 15)
        return startIndex..<endIndex
    }()
    
    private var selectedTextField: UITextField?
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker.backgroundColor = UIColor.white
        return picker
    }()
    
    private let datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.backgroundColor = UIColor.white
        return picker
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "in_ID")
        formatter.setLocalizedDateFormatFromTemplate("ddMMyy")
        return formatter
    }()
    
    private var getSelectedDateFormatted: String {
        get {
            dateFormatter.string(from: datePickerView.date)
        }
    }
    
    private var isProvinsiEmpty = true
    private var isKabupatenEmpty = true
    private var isKecamatanEmpty = true
    private var isGenderFemale = false
    
    private var kodeProvinsi: String?
    private var kodeKabupaten: String?
    private var kodeKecamatan: String?
    
    private var provinsiArray: [Provinsi] = [Provinsi]()
    private var kabupatenArray: [Kabupaten] = [Kabupaten]()
    private var kecamatanArray: [Kecamatan] = [Kecamatan]()
    private let genderArray = ["Pria", "Wanita"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        datePickerView.addTarget(self, action: #selector(changeBirthdayLabelText), for: .valueChanged)
        
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
        selectedTextField = provinsiTextField
    }
    
    @objc private func selectKabupatenTextField() {
        selectedTextField = kabupatenTextField
    }
    
    @objc private func selectKecamatanTextField() {
        selectedTextField = kecamatanTextField
    }
    
    @objc private func selectGenderTextField() {
        selectedTextField = genderTextField
    }
    
    @objc private func reloadPickerViewComponents() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pickerView.reloadAllComponents()
            for i in 0..<self.pickerView.numberOfComponents {
                self.pickerView.selectRow(0, inComponent: i, animated: true)
                break
            }
        }
    }
    
    private func changeKodeProvinsiLabelText() {
        guard let kode = kodeProvinsi else { return }
        guard let nikLabelText = getNikLabelText else { return }
        let replacedText = nikLabelText.replacingCharacters(in: provinsiTextRange, with: kode)
        nikLabel.text = replacedText
    }
    
    private func changeKodeKabupatenLabelText() {
        guard let kode = kodeKabupaten else { return }
        let cleanKabupatenKode = kode[kode.index(kode.endIndex, offsetBy: -2)..<kode.endIndex]
        let replacedText = nikLabel.text!.replacingCharacters(in: kabupatenTextRange, with: cleanKabupatenKode)
        nikLabel.text = replacedText
    }
    
    private func resetKodeKabupatenLabelText() {
        nikLabel.text = nikLabel.text!.replacingCharacters(in: kabupatenTextRange, with: "**")
    }
    
    private func changeKodeKecamatanLabelText() {
        guard let kode = kodeKecamatan else { return }
        let cleanKecamatanKode = kode[kode.index(kode.endIndex, offsetBy: -2)..<kode.endIndex]
        let replacedText = nikLabel.text!.replacingCharacters(in: kecamatanTextRange, with: cleanKecamatanKode)
        nikLabel.text = replacedText
    }
    
    private func resetKodeKecamatanLabelText() {
        nikLabel.text = nikLabel.text!.replacingCharacters(in: kecamatanTextRange, with: "**")
    }
    
    @objc private func changeBirthdayLabelText() {
        
        let cleanDate = getSelectedDateFormatted.replacingOccurrences(of: "/", with: "")
        
        if isGenderFemale {
            let dateRange = cleanDate.startIndex..<cleanDate.index(cleanDate.startIndex, offsetBy: 2)
            guard let dateInteger = Int(cleanDate[dateRange]) else { return }
            let modifiedDate = cleanDate.replacingCharacters(in: dateRange, with: String(dateInteger + 40))
            let replacedText = nikLabel.text!.replacingCharacters(in: birthDayTextRange, with: modifiedDate)
            nikLabel.text = replacedText
        } else {
            let replacedText = nikLabel.text!.replacingCharacters(in: birthDayTextRange, with: cleanDate)
            nikLabel.text = replacedText
        }
        
        birthdayTextField.text = getSelectedDateFormatted
    }
    
    private func changeGenderLabelText() {
        isGenderFemale = genderTextField.text == genderArray[1]
        if birthdayTextField.hasText {
            changeBirthdayLabelText()
        }
    }
    
    @objc private func onKodeUnikTextFieldHasChanged() {
        guard let kodeUnik = getValidatedKodeUnikText() else { return }
        guard let nikLabelText = getNikLabelText else { return }
        let startIndex = nikLabelText.index(nikLabelText.endIndex, offsetBy: -4)
        let endIndex = nikLabelText.endIndex
        let kodeUnikRange = startIndex..<endIndex
        let replacedText = nikLabelText.replacingCharacters(in: kodeUnikRange, with: kodeUnik)
        nikLabel.text = replacedText
    }
    
    private func getValidatedKodeProvinsiText() -> String? {
        if kodeProvinsi == nil { return "**" }
        return kodeProvinsi
    }
    
    private func getValidatedKodeUnikText() -> String? {
        guard var kodeUnik = kodeUnikTextField.text else { return nil }
        if kodeUnik.count > 4 {
            kodeUnik = String(kodeUnik.dropLast())
            kodeUnikTextField.text = kodeUnik
        } else if kodeUnik.count < 4 {
            for _ in 0..<(4 - kodeUnik.count) {
                kodeUnik.append("*")
            }
        }
        return kodeUnik
    }
    
    private func setEnableTextFields() {
        kabupatenTextField.isEnabled = !isProvinsiEmpty
        kecamatanTextField.isEnabled = !isKabupatenEmpty
    }
    
    private func setKodeProvinsi(_ kode: String?) {
        kodeProvinsi = kode
        kodeKabupaten = nil
        kodeKecamatan = nil
    }
    
    private func setKodeKabupaten(_ kode: String?) {
        kodeKabupaten = kode
        kodeKecamatan = nil
    }
    
    private func setKodeKecamatan(_ kode: String?) {
        kodeKecamatan = kode
    }
    
    private func setTanggalLahir(_ kode: String) {
        
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
        switch selectedTextField {
        case provinsiTextField:
            return provinsiArray.count
        case kabupatenTextField:
            return kabupatenArray.count
        case kecamatanTextField:
            return kecamatanArray.count
        case genderTextField:
            return genderArray.count
        default:
            return 0
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedTextField {
        case provinsiTextField:
            return provinsiArray[row].namaProvinsi
        case kabupatenTextField:
            return kabupatenArray[row].namaKabupaten
        case kecamatanTextField:
            return kecamatanArray[row].namaKecamatan
        case genderTextField:
            return genderArray[row]
        default:
            return nil
        }
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedTextField {
        case provinsiTextField:
            if kodeProvinsi != provinsiArray[row].kodeProvinsi {
                setKodeProvinsi(provinsiArray[row].kodeProvinsi)
                provinsiTextField.text = provinsiArray[row].namaProvinsi
                kabupatenTextField.text = nil
                kecamatanTextField.text = nil
                kabupatenArray = provinsiArray[row].kabupaten
                kecamatanArray.removeAll()
                isProvinsiEmpty = false
                changeKodeProvinsiLabelText()
                resetKodeKabupatenLabelText()
                resetKodeKecamatanLabelText()
            }
        case kabupatenTextField:
            if kodeKabupaten != kabupatenArray[row].kodeKabupaten {
                setKodeKabupaten(kabupatenArray[row].kodeKabupaten)
                kabupatenTextField.text = kabupatenArray[row].namaKabupaten
                kecamatanTextField.text = nil
                kecamatanArray = kabupatenArray[row].kecamatan
                isKabupatenEmpty = false
                isKecamatanEmpty = true
                changeKodeKabupatenLabelText()
                resetKodeKecamatanLabelText()
            }
        case kecamatanTextField:
            if kodeKecamatan != kecamatanArray[row].kodeKecamatan {
                setKodeKecamatan(kecamatanArray[row].kodeKecamatan)
                kecamatanTextField.text = kecamatanArray[row].namaKecamatan
                isKecamatanEmpty = false
                changeKodeKecamatanLabelText()
            }
        case genderTextField:
            genderTextField.text = genderArray[row]
            changeGenderLabelText()
        default:
            break
        }
        
        setEnableTextFields()
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == kodeUnikTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let isAllowed = allowedCharacters.isSuperset(of: characterSet)
            return isAllowed
        } else {
            return true
        }
    }
}
