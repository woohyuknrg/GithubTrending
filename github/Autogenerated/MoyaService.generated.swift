// Generated using Sourcery 0.10.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Moya

extension GitHub {
    public var path: String {
        switch self {
        case .token:
            return "authorizations"
        case .repoSearch:
            return "search/repositories"
        case .trendingReposSinceLastWeek:
            return "search/repositories"
        case let .repo(owner, repoName):
            return "repos\(owner)/\(repoName)"
        case let .repoReadMe(owner, repoName):
            return "repos\(owner)/\(repoName)/readme"
        case let .pulls(owner, repo):
            return "repos\(owner)/\(repo)/pulls"
        case let .issues(owner, repo):
            return "repos\(owner)/\(repo)/issues"
        case let .commits(owner, repo):
            return "repos\(owner)/\(repo)/commits"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .token:
            return .post
        default:
            return .get
        }
    }

    public var task: Moya.Task {
        var params = [String : Any]()
        var encoding: ParameterEncoding = URLEncoding.default

        switch self {
        case .token(let turple):
            params["scopes"] = turple.scopes
            params["note"] = turple.note
            encoding = JSONEncoding.default
        case .repoSearch(let turple):
            params["q"] = turple
        case .trendingReposSinceLastWeek(let turple):
            params["q"] = turple.q
            params["sort"] = turple.sort
            params["order"] = turple.order
        default:
            break
        }

        if !params.isEmpty {
            return .requestParameters(parameters: params, encoding: encoding)
        }
        return .requestPlain
    }

    public var sampleData: Data {
        switch self {
        case .token:
            return "Half measures are as bad as nothing at all.".data(using: .utf8)!
        case .repoSearch:
            return StubResponse.fromJSONFile("SearchResponse")
        case .trendingReposSinceLastWeek:
            return StubResponse.fromJSONFile("SearchResponse")
        case .repo(_,_):
            return "Half measures are as bad as nothing at all.".data(using: .utf8)!
        case .repoReadMe(_,_):
            return "Half measures are as bad as nothing at all.".data(using: .utf8)!
        case .pulls(_,_):
            return "[{\"title\": \"Avatar\", \"user\": { \"login\": \"me\" }, \"createdAt\": \"2011-01-26T19:01:12Z\" }]".data(using: .utf8)!
        case .issues(_,_):
            return "Half measures are as bad as nothing at all.".data(using: .utf8)!
        case .commits(_,_):
            return "Half measures are as bad as nothing at all.".data(using: .utf8)!
        }
    }

    public var headers: [String : String]? {
        switch self {
        case let .token(userString, passwordString, _, _):
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
}
