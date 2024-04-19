# WORK IN PROGRESS

-

<div id="top"></div>
<!-- PROJECT LOGO -->
<br />
<div align="center">

  <img src="./.github/assets/topos_logo.png#gh-light-mode-only" alt="Logo" width="200">
  <img src="./.github/assets/topos_logo_dark.png#gh-dark-mode-only" alt="Logo" width="200">

<br />

<p align="center">
Run the local ERC20 messaging infrastructure with docker compose 🐳
</p>

<br />

</div>

## Getting Started

**Install Docker**

https://docs.docker.com/get-docker/

## Stop

```sh
docker compose down -v
```

_Note_: The `-v` flag is important here to ensure that we clean up storage in between runs.

## Run

If you have a partial or complete existing run, it's recommended to shut down the whole stack (see [Stop](#stop)) before re-running it.

To run the whole stack:

```sh
docker compose up -d
```

## Resources

- Website: https://toposware.com
- Technical Documentation: https://docs.toposware.com
- Medium: https://toposware.medium.com
- Whitepaper: [Topos: A Secure, Trustless, and Decentralized
  Interoperability Protocol](https://arxiv.org/pdf/2206.03481.pdf)

## License

This project is released under the terms of the MIT license.
