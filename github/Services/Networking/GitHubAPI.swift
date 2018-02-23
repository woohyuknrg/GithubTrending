import Foundation
import Moya
import RxSwift

let GitHubProvider = MoyaProvider<GitHub>()

protocol MoyaService: TargetType {}

extension MoyaService {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}

public enum GitHub: MoyaService {
    /// sourcery:begin: noPathParam
    /// sourcery: method = "post", paramEncoding = "JSONEncoding", path = "authorizations", ignoreParams = "username|password"
    case token(username: String, password: String, scopes: [String], note: String)

    /// sourcery: path = "search/repositories"
    case repoSearch(q: String)

    /// sourcery: path = "search/repositories"
    case trendingReposSinceLastWeek(q: String, sort: String, order: String)
    /// sourcery:end

    /// sourcery:begin: noParam
    /// sourcery: path = "repos\(owner)/\(repoName)"
    case repo(owner: String, repoName: String)

    /// sourcery: path = "repos\(owner)/\(repoName)/readme"
    case repoReadMe(owner: String, repoName: String)

    /// sourcery: path = "repos\(owner)/\(repo)/pulls"
    case pulls(owner: String, repo: String)

    /// sourcery: path = "repos\(owner)/\(repo)/issues"
    case issues(owner: String, repo: String)

    /// sourcery: path = "repos\(owner)/\(repo)/commits"
    case commits(owner: String, repo: String)
    /// sourcery:end
}

extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
