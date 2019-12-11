//
//  CanvasView.swift
//  Atelier
//
//  Created by Atsushi Jike on 2019/12/02.
//  Copyright © 2019 Atsushi Jike. All rights reserved.
//

import UIKit

final class CanvasView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let circleSize = CGSize(width: 240, height: 240)

        // 球体の輪郭
        let circleView = UIView()
        circleView.backgroundColor = .green
        circleView.clipsToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = circleSize.width / 2
        addSubview(circleView)

        // 下から放射状に球体より大きめの円で黒いグラデーションをかけ暗い部分を表現する
        let bottomGradientView = GradientView()
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.style = .radial
        bottomGradientView.centerPoint = CGPoint(x: circleSize.width / 2, y: 0)
        bottomGradientView.endRadius = circleSize.width / 0.7
        bottomGradientView.colors = [UIColor(white: 0, alpha: 0),
                                     UIColor(white: 0, alpha: 1.0)]
        bottomGradientView.locations = [0.4, 1]
        circleView.addSubview(bottomGradientView)

        // 回り込みの表現
        let outlineGradientView = GradientView()
        outlineGradientView.translatesAutoresizingMaskIntoConstraints = false
        outlineGradientView.style = .radial
        outlineGradientView.colors = [UIColor(white: 1, alpha: 0),
                                      UIColor(white: 1, alpha: 0),
                                      UIColor(white: 1, alpha: 1)]
        outlineGradientView.locations = [0, 0.8, 1]
        circleView.addSubview(outlineGradientView)

        // 陰影
        // CATransform3DとCGGradientの合わせ技で落ちた影を表現する
        let shadowView = GradientView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.style = .radial
        shadowView.colors = [UIColor(white: 0, alpha: 0.7),
                             UIColor(white: 0, alpha: 0.4),
                             UIColor(white: 0, alpha: 0)]
        shadowView.locations = [0, 0.6, 1]
        var shadowTransform = CATransform3DIdentity
        shadowTransform.m34 = -1.0 / 500
        shadowTransform = CATransform3DRotate(shadowTransform, CGFloat(Double.pi * 0.4), 1, 0, 0)
        shadowView.layer.transform = shadowTransform
        insertSubview(shadowView, belowSubview: circleView)

        // 反射光を表現する
        let reflectionGradientView = GradientView()
        reflectionGradientView.translatesAutoresizingMaskIntoConstraints = false
        reflectionGradientView.colors = [UIColor(white: 1, alpha: 0.3),
                                         UIColor(white: 1, alpha: 0),
                                         UIColor(white: 1, alpha: 0)]
        reflectionGradientView.locations = [1, 0.4, 0]
        circleView.addSubview(reflectionGradientView)

        // 映り込みの表現
        let mirroredView = GradientView()
        mirroredView.translatesAutoresizingMaskIntoConstraints = false
        mirroredView.clipsToBounds = true
        mirroredView.colors = [UIColor(white: 0.7, alpha: 0.2),
                               UIColor(white: 0.7, alpha: 0)]
        mirroredView.locations = [0, 0.8]
        mirroredView.layer.cornerRadius = circleSize.width * 0.7 / 2
        let maskLayer = CAShapeLayer()
        let mutablePath = CGMutablePath()
        // 反転するために外枠をaddEllipse
        mutablePath.addEllipse(in: CGRect(x: 0, y: 0, width: circleSize.width * 0.9, height: circleSize.height * 0.6))
        mutablePath.addEllipse(in: CGRect(x: circleSize.width * 0.1, y: 0, width: circleSize.width * 0.7, height: circleSize.height * 0.6))
        maskLayer.path = mutablePath
        // 反転するために.eventOddを指定
        maskLayer.fillRule = .evenOdd
        // マスクする
        mirroredView.layer.mask = maskLayer
        circleView.addSubview(mirroredView)

        // 映り込みの表現２
        let filter: CIFilter? = {
            if let image = UIImage(named: "room.jpg"),
                let inputImage = CIImage(image: image) {
                let filter = CIFilter(name: "CIBumpDistortion")
                filter?.setValue(inputImage, forKey: kCIInputImageKey)
                filter?.setValue(CIVector(x: circleSize.width / 2, y: circleSize.height / 2), forKey: kCIInputCenterKey)
                filter?.setValue(NSNumber(value: Float(circleSize.width / 2)), forKey: kCIInputRadiusKey)
                filter?.setValue(NSNumber(value: 1.5), forKey: kCIInputScaleKey)
                return filter
            }
            return nil
        }()
        if let outputImage = filter?.outputImage {
            let imageMirroredView = UIImageView(image: UIImage(ciImage: outputImage))
            imageMirroredView.contentMode = .scaleAspectFill
            let imageMaskLayer = CAGradientLayer()
            imageMaskLayer.frame.size = circleSize
            // 中心から外にかかるようにする
            imageMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            imageMaskLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            // 10%->10%->0%とかかるようにする
            imageMaskLayer.colors = [UIColor(white: 0, alpha: 0.1).cgColor,
                                     UIColor(white: 0, alpha: 0.1).cgColor,
                                     UIColor.clear.cgColor]
            imageMaskLayer.type = .radial
            imageMirroredView.layer.mask = imageMaskLayer
            circleView.addSubview(imageMirroredView)

            NSLayoutConstraint.activate([
                imageMirroredView.widthAnchor.constraint(equalTo: circleView.widthAnchor),
                imageMirroredView.heightAnchor.constraint(equalTo: circleView.heightAnchor),
                imageMirroredView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
                imageMirroredView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 0),
            ])
        }

        // ハイライト部分。重なり順の関係もあるので最後に一番上に追加。
        let topGradientView = GradientView()
        topGradientView.translatesAutoresizingMaskIntoConstraints = false
        topGradientView.style = .radial
        topGradientView.centerPoint = CGPoint(x: circleSize.width / 2, y: circleSize.height / 2)
        topGradientView.colors = [UIColor(white: 1, alpha: 1),
                             UIColor(white: 1, alpha: 0.5),
                             UIColor(white: 1, alpha: 0)]
        topGradientView.locations = [0, 0.5, 1]
        var topGradientTransform = CATransform3DIdentity
        topGradientTransform.m34 = -1.0 / 500
        topGradientTransform = CATransform3DTranslate(topGradientTransform, 0, -circleSize.height * 0.4, 0)
        topGradientTransform = CATransform3DRotate(topGradientTransform, CGFloat(Double.pi * 0.2), 1, 0, 0)
        topGradientView.layer.transform = topGradientTransform
        circleView.addSubview(topGradientView)

        // AutoLayout
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            circleView.widthAnchor.constraint(equalToConstant: circleSize.width),
            circleView.heightAnchor.constraint(equalToConstant: circleSize.height),
            bottomGradientView.heightAnchor.constraint(equalTo: circleView.heightAnchor),
            bottomGradientView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
            bottomGradientView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 0),
            bottomGradientView.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            outlineGradientView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
            outlineGradientView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 0),
            outlineGradientView.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 1.1),
            outlineGradientView.heightAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 1.1),
            shadowView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            shadowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: circleSize.height * 0.5),
            shadowView.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            shadowView.heightAnchor.constraint(equalTo: circleView.heightAnchor),
            reflectionGradientView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
            reflectionGradientView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 0),
            reflectionGradientView.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            reflectionGradientView.heightAnchor.constraint(equalTo: circleView.heightAnchor),
            mirroredView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
            mirroredView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 0),
            mirroredView.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 0.9),
            mirroredView.heightAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 0.6),
            topGradientView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 0),
            topGradientView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 0),
            topGradientView.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            topGradientView.heightAnchor.constraint(equalTo: circleView.heightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class GradientView: UIView {
    enum Style {
        case linear, radial
    }
    var style: Style = .linear
    var colors: [UIColor] = [.white, .black]
    var centerPoint: CGPoint?
    var endRadius: CGFloat?
    var locations: [CGFloat] = [0, 1]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let cgColors = colors.map({ $0.cgColor }) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        if let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: space, colors: cgColors, locations: locations) {
            switch style {
            case .linear:
                context.drawLinearGradient(gradient,
                                           start: .zero,
                                           end: CGPoint(x: 0, y: rect.maxY),
                                           options: [])
            case .radial:
                context.drawRadialGradient(gradient,
                                           startCenter: centerPoint ?? CGPoint(x: rect.midX, y: rect.midY),
                                           startRadius: 0,
                                           endCenter: centerPoint ?? CGPoint(x: rect.midX, y: rect.midY),
                                           endRadius: endRadius ?? rect.width / 2,
                                           options: [])
            }
        }
    }
}
