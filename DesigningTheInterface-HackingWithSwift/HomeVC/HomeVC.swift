//
//  HomeVC.swift
//  DesigningTheInterface-HackingWithSwift
//
//  Created by Mert Deniz Akbaş on 22.08.2023.
//

import UIKit
import CoreImage

protocol HomeVCProtocol: AnyObject {
    func setCoreImage()
    
}

final class HomeVC: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var intensityLabel: UILabel!
    @IBOutlet private weak var changeFilterButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    private var currentImage: UIImage!
    private var currentFilter: CIFilter!
    private var context: CIContext!
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        title = "InstaFilter"
        setAddButton()
      
    }
    
    @IBAction private func changeFilterButtonClicked(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(ac, animated: true)
    }
    func setFilter(action: UIAlertAction) {
        guard  currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        currentFilter = CIFilter(name: actionTitle)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
       
    }
    
    @IBAction private func saveButtonClicked(_ sender: UIButton) {
        guard let imageView = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageView, self, #selector(image), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextOf: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved", message: "It's okey", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction private func intensityChanged(_ sender: Any) {
        applyProcessing()
    }

}

extension HomeVC: HomeVCProtocol {
    
    func setCoreImage() {
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
}

extension HomeVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func setAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importImage))
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(slider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(slider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(slider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }

        guard let image = currentFilter.outputImage else { return }
           if let cgimg = context.createCGImage(image, from: image.extent) {
               let processedImage = UIImage(cgImage: cgimg)
               imageView.image = processedImage
           }
    }
    
    @objc func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}
