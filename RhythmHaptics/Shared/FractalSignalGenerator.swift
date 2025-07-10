import Foundation

// Generates a fractal time series using the Fourier filtering method
func generateFractalSignal(length: Int, hurst: Double = 1) -> [Double] {
    let alpha = 2 * hurst - 1
    let n = length
    var reals = [Double](repeating: 0, count: n)
    var imags = [Double](repeating: 0, count: n)
    var spectrum = [Double](repeating: 0, count: n)
    let twoPi = 2 * Double.pi

    for i in 0..<n/2 {
        let freq = Double(i + 1)
        let amplitude = pow(freq, -alpha / 2.0)
        let phase = Double.random(in: 0..<twoPi)
        reals[i] = amplitude * cos(phase)
        imags[i] = amplitude * sin(phase)
    }
    for i in n/2..<n {
        reals[i] = reals[n - i]
        imags[i] = -imags[n - i]
    }

    for t in 0..<n {
        var sum = 0.0
        for k in 0..<n {
            let angle = twoPi * Double(k) * Double(t) / Double(n)
            sum += reals[k] * cos(angle) - imags[k] * sin(angle)
        }
        spectrum[t] = sum / Double(n)
    }

    let minVal = spectrum.min() ?? 0
    let maxVal = spectrum.max() ?? 1
    let normalized = spectrum.map { ($0 - minVal) / (maxVal - minVal) }
    return normalized
}
