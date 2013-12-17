%requires fsevent

class Watcher inherits public FSWatcher
{
private {
    $.acts = ("1" : "ADD", "2" : "DELETE", "3" : "MODIFIED", "4" : "MOVED", );
}
constructor() : FSWatcher() {
}

string strAction(softstring $action) {
    return $.acts.$action;
}

nothing event(int $id, string $dir, string $fname, int $action, string $oldFname) {
    printf("Qore FS event: %d, %s, %s, %s(%d), %s\n", $id, $dir, $fname, $.strAction($action), $action, $oldFname);
}

} # class Watcher


my Watcher $fw();

my int $id = $fw.addPath("/var/log/", True);

while(1) {
    sleep(1);
}

