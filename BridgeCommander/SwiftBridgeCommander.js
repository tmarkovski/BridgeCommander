var SwiftBridgeCommander = function() {
    
    window["__SWIFT_BRIDGE_COMMANDER_JS_OBJECT"] = this;
    
    this.uuid = function() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                                                              var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
                                                              return v.toString(16);
                                                              });
    };
    
    this.nativeCommandStack = [];
    
    this.call = function(command, args, onResponse, onError) {
        var message = {
        id: this.uuid(),
        command: command,
        args: args || "",
        response: onResponse,
        error: onError
        };
        this.nativeCommandStack.push(message);
        
        window.webkit.messageHandlers["__SWIFT_BRIDGE_COMMANDER"].postMessage(JSON.stringify(message));
    };
    
    this.find = function(id) {
        var result;
        for (var i = 0; i <= this.nativeCommandStack.length; i++) {
            if (this.nativeCommandStack[i].id === id) {
                result = this.nativeCommandStack[i];
                this.nativeCommandStack.splice(i, 1);
                break;
            }
        }
        return result;
    };
    
    this.response = function(data) {
        var item = this.find(data.id);
        if (item)
            item.response(data.payload);
    };
    
    this.error = function(data) {
        var item = this.find(data.id);
        if (item)
            item.error(data.payload);
    };
};
window.sbc = new SwiftBridgeCommander();
