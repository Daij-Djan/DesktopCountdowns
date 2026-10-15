# Contributing to DesktopCountdowns

Thanks for wanting to help! Bug reports, ideas and pull requests are all welcome.

## License of contributions

DesktopCountdowns is licensed under the GNU General Public License v3.0 with an
additional permission that allows distribution through app stores such as Apple's
App Store (see [LICENSE](LICENSE)).

By contributing, you agree that your contribution is licensed under the same terms,
including that additional permission. You keep the copyright to your work.

## Developer Certificate of Origin (DCO)

Every commit in a pull request must be signed off to certify that you wrote the
change, or otherwise have the right to submit it under the project's license.
This is the [Developer Certificate of Origin](https://developercertificate.org/),
version 1.1:

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

### How to sign off

Add a `Signed-off-by` line with your real name and email to each commit message:

```
Signed-off-by: Jane Doe <jane@example.com>
```

Git does this for you with the `-s` flag:

```sh
git commit -s -m "Fix countdown for all-day reminders"
```

To sign off commits you already made on your branch:

```sh
git rebase --signoff main
git push --force-with-lease
```

Pull requests with commits that are not signed off can't be merged.

## Pull requests

- Keep changes focused; one topic per pull request.
- Make sure the project builds for the platforms you touched, and run SwiftLint
  (configured in `.swiftlint.yml`).
- Use only public Apple APIs in new code, so the app stays eligible for the App Store.
