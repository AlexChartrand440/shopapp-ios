//
//  ProductsParametersBuilder.swift
//  ShopApp
//
//  Created by Radyslav Krechet on 4/27/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire

enum FilterCondition: String {
    case equal = "eq"
    case notEqual = "neq"
    case like
}

enum SortOrderDirection: String {
    case ASC, DESC
}

private enum SearchCriteria: String {
    case filterGroups, sortOrders, pageSize, currentPage
}

private enum FilterCriteria: String {
    case field
    case value
    case conditionType = "condition_type"
}

private enum SortOrdersCriteria: String {
    case field, direction
}

class ProductsParametersBuilder {
    private let filterParametersCount = 3
    
    private var filterParameters = Parameters()
    private var sortOrderParameters = Parameters()
    private var paginationParameters = Parameters()
    
    func addFilterParameters(field: String, value: String, condition: FilterCondition = .equal) -> ProductsParametersBuilder {
        let index = String(filterParameters.count / filterParametersCount)
        
        filterParameters[SearchCriteriasBuilder().addFilterGroupsCriteria(with: index, filterCriteria: .field).build()] = field
        filterParameters[SearchCriteriasBuilder().addFilterGroupsCriteria(with: index, filterCriteria: .value).build()] = value
        filterParameters[SearchCriteriasBuilder().addFilterGroupsCriteria(with: index, filterCriteria: .conditionType).build()] = condition.rawValue
        
        return self
    }
    
    func addSortOrderParameters(field: String, isRevers: Bool = false) -> ProductsParametersBuilder {
        let direction: SortOrderDirection = isRevers ? .DESC : .ASC
        
        sortOrderParameters[SearchCriteriasBuilder().addSortOrderCriteria(with: .field).build()] = field
        sortOrderParameters[SearchCriteriasBuilder().addSortOrderCriteria(with: .direction).build()] = direction.rawValue
        
        return self
    }
    
    func addPaginationParameters(pageSize: Int = kItemsPerPage, currentPage: Int) -> ProductsParametersBuilder {
        paginationParameters[SearchCriteriasBuilder().addPageSizeCriteria().build()] = pageSize
        paginationParameters[SearchCriteriasBuilder().addCurrentPageCriteria().build()] = currentPage
        
        return self
    }
    
    func build() -> Parameters {
        var parameters = Parameters()
        
        parameters.merge(filterParameters) { (current, _) in current }
        parameters.merge(sortOrderParameters) { (current, _) in current }
        parameters.merge(paginationParameters) { (current, _) in current }
        
        return parameters
    }
}

private class SearchCriteriasBuilder {
    private let rootCriteria = "searchCriteria"
    private let filters = "filters"
    private let defaultIndex = "0"
    private let criteriaFormat = "[%@]"
    
    private var searchCriterias: [String] = []
    
    func addFilterGroupsCriteria(with index: String, filterCriteria: FilterCriteria) -> SearchCriteriasBuilder {
        searchCriterias.append(SearchCriteria.filterGroups.rawValue)
        searchCriterias.append(index)
        searchCriterias.append(filters)
        searchCriterias.append(defaultIndex)
        searchCriterias.append(filterCriteria.rawValue)
        
        return self
    }
    
    func addSortOrderCriteria(with sortOrdersCriteria: SortOrdersCriteria) -> SearchCriteriasBuilder {
        searchCriterias.append(SearchCriteria.sortOrders.rawValue)
        searchCriterias.append(defaultIndex)
        searchCriterias.append(sortOrdersCriteria.rawValue)
        
        return self
    }
    
    func addPageSizeCriteria() -> SearchCriteriasBuilder {
        searchCriterias.append(SearchCriteria.pageSize.rawValue)
        
        return self
    }
    
    func addCurrentPageCriteria() -> SearchCriteriasBuilder {
        searchCriterias.append(SearchCriteria.currentPage.rawValue)
        
        return self
    }
    
    func build() -> String {
        return searchCriterias.reduce(rootCriteria, { $0 + String(format: criteriaFormat, arguments: [$1]) })
    }
}