//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Евгений Житников on 27.04.2023.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    // Создаем свойства базового URL и API-ключа
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "" //вставить API

    // Создаем массив доступных валют
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    // Создаем функцию getCoinPrice для получения цены на криптовалюту
    func getCoinPrice(for currency: String) {
        
        // Формируем URL-строку для запроса к API
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)
        
        // Если URL корректен, то создаем сессию URLSession и начинаем выполнение задачи dataTask
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
                // Если при выполнении задачи произошла ошибка, то вызываем метод didFailWithError делегата
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                // Если данные получены успешно, то вызываем метод parseJSON для их обработки
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    // Создаем функцию parseJSON для обработки полученных данных в формате JSON
    func parseJSON(_ data: Data) -> Double? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
            // Если при обработке данных произошла ошибка, то вызываем метод didFailWithError делегата
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
