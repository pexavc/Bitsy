import Granite

struct RemoteService: GraniteService {
    @Service(.online) var center: Center
}
