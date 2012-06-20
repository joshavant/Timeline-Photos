# Timeline Photos
**An iPhone app which allows you to post photos to your Facebook Timeline at the correct location in time.**

![image](http://iamjo.sh/github-images/timeline_photos/1.png)![image](http://iamjo.sh/github-images/timeline_photos/2.png)

## Discussion
This relies on the [libTPTimelineUpload](https://github.com/joshavant/libTPTimelineUpload) library, which is an unofficial interface to Facebook's Timeline. **Facebook could break this library at any time, which would also break this app.**

To bypass the login flow, such as for debugging, comment `[self switchToLoginNavController]` and uncomment `[self switchToUserNavController]` within `application:didFinishLaunchingWithOptions:` inside `TPAppDelegate.m`.

## Compatibility
* iOS 4.3+ w/ ARC
* Xcode 4.x

**Contributions, corrections, and improvements are always appreciated!**

## Created By
Josh Avant

## Copyright
[Hipster, Inc.](http://www.hipster.com)

## License
This is licensed under a BSD License:

    Created by Josh Avant
    Copyright (c) 2012 Hipster, Inc.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

    Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.