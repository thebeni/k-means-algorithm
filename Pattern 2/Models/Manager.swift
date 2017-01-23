//
//  Manager.swift
//  Pattern 2
//
//  Created by Arben Pnishi on 1/22/17.
//  Copyright © 2017 Arben Pnishi. All rights reserved.
//

import UIKit
import Foundation

let K_MEANS_MAXIMUM_COUNT = 100

enum CalculationType: Int {
    case eucledian = 1
    case manhattan
    case eucledianSquared
    case chebyshev
}

class Manager: NSObject {
    var centroids: Cluster = Cluster.init()
    var tests: Cluster = Cluster.init()
    
    var categories: [Int] = [Int]()
    
    var calculationType : CalculationType = .eucledian
    
    override init(){
        super.init()
        resetValues()
    }
    
    func resetValues(){
        centroids = Cluster.init(text: "centroids.txt".contentsOrBlank())
        tests = Cluster.init(text: "test.txt".contentsOrBlank())
        categories = [Int] (repeating: 0, count: centroids.instances.count)
    }
    
    func normalizeValues() {
        normalizeValuesIn(cluster: centroids)
        normalizeValuesIn(cluster: tests)
    }
    
    func normalizeValuesIn(cluster: Cluster){
        for sample in cluster.instances {
            let max: Float = sample.features.max()!
            let min: Float = sample.features.min()!
            
            for i in 0 ..< sample.features.count{
                sample.features[i] = (sample.features[i] - min) / (max - min)
            }
        }
    }
    
    func useKMeansAlgorithm(){
        resetValues()
        normalizeValues()
        
        for _ in 0 ..< K_MEANS_MAXIMUM_COUNT{
            for test in tests.instances {
                test.distances.removeAll()
                for centroid in centroids.instances {
                    var distance : Float = 0
                    switch calculationType {
                    case .eucledian:
                        distance = calculateEucledianDistance(instance: test.features, centroid: centroid.features)
                        
                    case .manhattan:
                        distance = calculateManhattanDistance(instance: test.features, centroid: centroid.features)
                        
                    case .eucledianSquared:
                        distance = calculateEuclideanSquaredDistance(instance: test.features, centroid: centroid.features)
                        
                    case .chebyshev:
                        distance = calculateChebyshevDistance(instance: test.features, centroid: centroid.features)
                        
                    }
                    test.distances.append(distance)
                }
                test.correspondsToCentroid = test.distances.index(of: test.distances.min()!)!
                centroids.instances[test.correspondsToCentroid].corresponds.append(test)
            }
            repositionCentroid()
        }
        findCategories()
    }
    
    func repositionCentroid(){
        for i in 0 ..< centroids.instances.count{
            let centroid = centroids.instances[i]
            
            for j in 0 ..< centroid.features.count {
                
                var sum: Float = 0.0
                
                for k in 0 ..< centroid.corresponds.count {
                    sum += centroid.corresponds[k].features[j]
                }
                centroid.features[j] = sum / Float(centroid.corresponds.count)
            }
            centroid.corresponds.removeAll()
        }
    }
    
    func findCategories(){
        for instance in tests.instances {
            categories[instance.correspondsToCentroid] += 1
        }
    }
    
    private func calculateEucledianDistance(instance: [Float], centroid: [Float]) -> Float{
        var distance: Float = 0.0
        
        for i in 0 ..< centroid.count{
            distance += powf(instance[i] - centroid[i], 2)
        }
        return sqrtf(distance)
    }
    
    private func calculateManhattanDistance(instance: [Float], centroid: [Float])-> Float{
        var distance: Float = 0.0
        
        for i in 0 ..< centroid.count{
            distance += abs(instance[i] - centroid[i])
        }
        return distance
    }
    
    private func calculateEuclideanSquaredDistance(instance: [Float], centroid: [Float])-> Float{
        var distance: Float = 0.0
        
        for i in 0 ..< centroid.count{
            distance += powf(instance[i] - centroid[i], 2)
        }
        return distance
    }
    
    private func calculateChebyshevDistance(instance: [Float], centroid: [Float])-> Float{
        var distance: Float = 0.0
        
        //    for i in 0 ..< centroid.count{
        //        distance += abs(instance[i] - centroid[i])
        //    }
        return distance
    }
    
}
public extension String {
    func contentsOrBlank()->String {
        if let path = Bundle.main.path(forResource:self , ofType: nil) {
            do {
                let text = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                return text
            } catch { print("Failed to read text from bundle file \(self)") }
        } else { print("Failed to load file from bundle \(self)") }
        return ""
    }
}