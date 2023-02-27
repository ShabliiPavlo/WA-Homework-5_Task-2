//
//  ViewController.swift
//  DZ.4-6
//
//  Created by Pavel Shabliy on 13.02.2023.
//

import UIKit
import Alamofire
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try? Realm()
    
    var dataArray = [DataFromTMDb]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableViewCell()
        self.clearCache()
        self.updateMovies()
    }
    
    private func setupTableViewCell() {
        myTableView.register(UITableViewCell.self , forCellReuseIdentifier: "Cell")
    }
    
    private func updateMovies() {
        let urlTrends = "https://api.themoviedb.org/3/trending/movie/week?api_key=ecc058e6ce27c2951f183a27b82edc03"
        AF.request(urlTrends).responseJSON {  response in
            do{
                
                let decoder = JSONDecoder()
                let allData = try decoder.decode(Trends.self, from: response.data!)
                let dataArray = allData.results ?? []
                self.saveInRealm(movies: dataArray)
                self.dataArray = self.getFromRealm()
                self.myTableView.reloadData()
        
            } catch {
                
                print(error)
            }
        }
    }
    
    func saveInRealm(movies: [Movie]) {
        
        for movie in movies {
            let tmdb = DataFromTMDb()
            tmdb.filmName = movie.title ?? ""
            try? realm?.write {
                realm?.add(tmdb)
            }
            print(tmdb)
        }
    }
    
    func getFromRealm() -> [DataFromTMDb] {
        var dataArray = [DataFromTMDb]()
        let tmdbResults = realm?.objects(DataFromTMDb.self)
        
        if let tmdbResults = realm?.objects(DataFromTMDb.self) {
            for someResult in tmdbResults {
                dataArray.append(someResult)
            }
        }
        print(dataArray.last!.filmName.count)
        return dataArray
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let data = dataArray[indexPath.row]
        
        cell.textLabel?.text = "\(data.filmName)"
        return cell
    }
    func clearCache() {
           try? realm?.write {
               realm?.deleteAll()
           }
           dataArray = []
           myTableView.reloadData()
       }
}




