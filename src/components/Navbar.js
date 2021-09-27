import React from 'react'
import { Link } from 'gatsby'
import { OutboundLink } from 'gatsby-plugin-google-gtag'

import useSiteMetadata from '../queries/site-metadata'

import Logo from './Logo'

export default function Navbar() {
  const { title } = useSiteMetadata()

  return (
    <header>
      <div className="h-24 z-50 relative container mx-auto px-6 grid grid-cols-3">
        <div className="flex items-center">
          <Link to={`/`} href="/" className="text-white uppercase font-bold text-2xl tracking-widest">
            <Logo className="h-20 w-64 object-contain object-center" />
            {title}
          </Link>
        </div>

        <div className="flex items-center justify-end">
          <ul className="list-reset lg:flex justify-end flex-1 items-center">
            <li className="mr-3">
              <Link to={`/about`} className="inline-block text-white no-underline hover:text-gray-800 hover:text-underline py-2 px-4">Notre pourquoi</Link>
            </li>
            <li className="mr-3">
              <Link to={`/precedent`} className="inline-block text-white no-underline hover:text-gray-800 hover:text-underline py-2 px-4">Les replays</Link>
            </li>
          </ul>
          <OutboundLink
            href="https://www.meetup.com/archilocus/events/280992564/"
            className="mx-auto lg:mx-0 hover:underline bg-white text-gray-800 font-bold rounded-full mt-4 lg:mt-0 py-4 px-8 shadow opacity-75 focus:outline-none focus:shadow-outline transform transition hover:scale-105 duration-300 ease-in-out"
          >
            Inscription
          </OutboundLink>
        </div>
      </div>

      <div className="w-full h-24 bg-yellow-900 bg-opacity-95 absolute top-0 left-0"></div>
    </header>
  )
}
