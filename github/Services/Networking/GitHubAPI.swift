import Foundation
import Moya
import RxSwift

let GitHubProvider = MoyaProvider<GitHub>()

public enum GitHub {
    /// sourcery: method = "GET", path = "/spaceships"
    case token(username: String, password: String)
    case repoSearch(query: String)
    case trendingReposSinceLastWeek
    case repo(owner: String, repoName: String)
    case repoReadMe(owner: String, repoName: String)
    case pulls(onwer: String, repo: String)
    case issues(onwer: String, repo: String)
    case commits(onwer: String, repo: String)
}

extension GitHub: TargetType {
    public var headers: [String : String]? {
        switch self {
        case let .token(userString, passwordString):
            let credentialData = "\(userString):\(passwordString)".data(using: .utf8)!
            let base64Credentials = credentialData.base64EncodedString()
            return ["Authorization": "Basic \(base64Credentials)"]
        default:
            let appToken = Token()
            guard let token = appToken.token else {
                return nil
            }
            return ["Authorization": "token \(token)"]
        }
    }

    public var baseURL: URL { return URL(string: "https://api.github.com")! }
    
    public var path: String {
        switch self {
        case .token(_, _):
            return "/authorizations"
        case .repoSearch(_),
        .trendingReposSinceLastWeek:
            return "/search/repositories"
        case .repo(let owner, let repoName):
            return "/repos\(owner)/\(repoName)"
        case .repoReadMe(let owner, let repoName):
            return "/repos\(owner)/\(repoName)/readme"
        case .pulls(let owner, let repo):
            return "/repos\(owner)/\(repo)/pulls"
        case .issues(let owner, let repo):
            return "/repos\(owner)/\(repo)/issues"
        case .commits(let owner, let repo):
            return "/repos\(owner)/\(repo)/commits"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .token(_, _):
            return .post
        case .repoSearch(_),
        .trendingReposSinceLastWeek,
        .repo(_,_),
        .repoReadMe(_,_),
        .pulls(_,_),
        .issues(_,_),
        .commits(_,_):
            return .get
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .token(_, _):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .repoSearch(_):
            return StubResponse.fromJSONFile("SearchResponse")
        case .trendingReposSinceLastWeek:
            return StubResponse.fromJSONFile("SearchResponse")
        case .repo(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .repoReadMe(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .pulls(_,_):
            return "[{\"title\": \"Avatar\", \"user\": { \"login\": \"me\" }, \"createdAt\": \"2011-01-26T19:01:12Z\" }]".data(using: String.Encoding.utf8)!
        case .issues(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .commits(_,_):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        var parameters: [String : Any]? = nil
        var encoding: ParameterEncoding = URLEncoding.default
        switch self {
        case .token(_, _):
            parameters = ["scopes": ["public_repo", "user"], "note": "Ori iOS app (\(Date()))"]
            encoding = JSONEncoding.default
        case .repoSearch(let query):
            parameters = ["q": query.URLEscapedString]
        case .trendingReposSinceLastWeek:
            parameters = ["q" : "created:>" + Date().lastWeek(), "sort" : "stars", "order" : "desc"]
        default:
            break
        }

        if let params = parameters {
            return .requestParameters(parameters: params, encoding: encoding)
        }
        return .requestPlain
    }
}

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
