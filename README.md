# DWT-SVD Digital Image Watermarking System

A MATLAB-based Digital Image Watermarking System using **Discrete Wavelet Transform (DWT)** and **Singular Value Decomposition (SVD)** for secure watermark embedding and extraction.

---

# 📌 Project Overview

This project implements a robust digital image watermarking technique using a hybrid **DWT-SVD** approach. The watermark is embedded into the **HL2 sub-band** obtained from a **2-Level DWT decomposition**, improving imperceptibility while maintaining robustness against different image processing attacks.

The system also provides a MATLAB GUI for:
- Watermark embedding
- Watermark extraction
- Attack simulation
- Performance evaluation

---

# 🚀 Features

- 2-Level DWT based watermarking
- SVD-based singular value embedding
- GUI-based implementation
- Watermark extraction
- Multiple attack simulation
- PSNR, SSIM, and NC evaluation
- Support for grayscale and color images

---

# 🛠️ Technologies Used

- MATLAB
- MATLAB App Designer
- Image Processing Toolbox
- Discrete Wavelet Transform (DWT)
- Singular Value Decomposition (SVD)

---

# 📂 Project Structure

```text
watermark-dwt-matlab-master/
│
├── gui.m
├── logic.m
├── README.md
├── screenshots/
<img width="2988" height="1658" alt="image" src="https://github.com/user-attachments/assets/7b4bf571-b26f-482e-a8b2-b615544492af" />

└── report/
--------

Workflow
Load Source Image
Load Watermark Image
Apply 2-Level DWT
Select HL2 sub-band
Apply SVD on HL2 and watermark image
Modify singular values using alpha factor
Reconstruct the watermarked image
Apply attacks (optional)
Extract watermark
Compute PSNR, SSIM, and NC metrics
Core Concepts UsedDiscrete Wavelet Transform (DWT)

DWT decomposes the image into multiple frequency sub-bands:

LL → Approximation coefficients
LH → Horizontal details
HL → Vertical details
HH → Diagonal details

This project uses 2-Level DWT decomposition and embeds the watermark into the HL2 sub-band.

Singular Value Decomposition (SVD)

SVD decomposes a matrix into:

A = U × S × Vᵀ

Where:

U → Orthogonal matrix
S → Singular values
Vᵀ → Transpose orthogonal matrix

The watermark is embedded by modifying the singular values of the HL2 sub-band.

📊 Performance Metrics

The system evaluates performance using:

🔸 PSNR (Peak Signal-to-Noise Ratio)

Measures image quality between original and watermarked image.

Higher PSNR indicates better visual quality.

🔸 SSIM (Structural Similarity Index)

Measures structural similarity between images.

Values closer to 1 indicate higher similarity.

🔸 NC (Normalized Correlation)

Measures similarity between original and extracted watermark.

Values closer to 1 indicate successful extraction.

🧪 Attacks Implemented

The system supports the following attacks:

Blurring
Sharpening
Resize
Gaussian Noise
Salt & Pepper Noise
Cropping
Rotation
GUI Preview
Main GUI

Add your screenshots inside the screenshots/ folder.

![GUI](screenshots/gui.png)
# Sample Results
Attack	PSNR (Cameraman)	SSIM
No Attack	30.60 dB	0.9621
Blur	24.42 dB	0.7791
Sharpen	24.87 dB	0.7948
Resize	26.09 dB	0.8650
Gaussian Noise	19.33 dB	0.2839
Salt & Pepper Noise	17.47 dB	0.2316
Cropping	11.60 dB	0.0693
Rotation	11.24 dB	0.0785

Research Basis

This project is inspired by various DWT-SVD based digital image watermarking research papers and extends them using:

2-Level DWT
HL2 sub-band embedding
GUI-based implementation
Attack simulation
Additional evaluation metrics

#Limitations
Sensitive to severe geometric attacks
Performance depends on alpha value
Noise significantly affects extraction quality
Implemented mainly for grayscale/single-channel processing

# Future Scope
Integration with Deep Learning techniques
Color image watermarking
Video watermarking
Web-based implementation
Improved robustness against geometric attacks
