trigger helloWorldTrigger on Account (before insert) {
    System.debug('Hello World!');
}