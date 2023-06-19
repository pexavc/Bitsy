import Granite

struct Stream: GraniteComponent {
    @Command var center: Center
    @Relay var service: RemoteService
}
