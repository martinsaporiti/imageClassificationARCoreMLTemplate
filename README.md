#  Template para la construcción de apps utilizando ARKit y CoreML

Este template utiliza CoreML nativo y tiene cargado por defecto el Inceptionv3 model.


### Inception v3
"Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more."
Se pueden incorporrar otros modelos que pueden obtenerase, por ejemplo, del siguiente link: https://developer.apple.com/machine-learning/

### Notas de interés:

La manera de obtener la imágen de la cámara del ARKit se realizó de la siguiente manera

```
let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)

if pixbuff == nil { return }

let ciImage = CIImage(cvPixelBuffer: pixbuff!)

```
El setUp de Vision lo realiza la siguiente función:

```
func setUpVision(){
    guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model)
    else { fatalError("Can't load VisionML model") }

    let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)

    classificationRequest.imageCropAndScaleOption = .centerCrop

    self.requests = [classificationRequest]
}
```
