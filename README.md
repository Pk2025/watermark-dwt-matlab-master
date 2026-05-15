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


# Screenshot

<img width="2988" height="1658" alt="image" src="https://github.com/user-attachments/assets/7b4bf571-b26f-482e-a8b2-b615544492af" />




# Workflow
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

# 📄 Research Paper and Conference Presentation

This project was presented at the:

**2nd International Conference on Emerging Technologies & Innovations (ICETI 2026)**

## Paper Title
**Digital Image Watermarking Using DWT-SVD in MATLAB**

## Research Contribution
The proposed system uses a hybrid DWT-SVD watermarking approach with 2-Level DWT decomposition and HL2 sub-band embedding to improve watermark imperceptibility and robustness against various image processing attacks.

The system was implemented in MATLAB with a GUI-based interface supporting:
- Watermark embedding
- Watermark extraction
- Attack simulation
- Performance analysis using PSNR, SSIM, and NC metrics

## Conference Presentation
The work was accepted and presented as part of the ICETI 2026 conference proceedings.



