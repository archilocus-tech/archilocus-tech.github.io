import { Link } from 'gatsby'
import React from 'react'
import PropTypes from 'prop-types'

const EventCard = ({ title, description, path }) => (
  <div className="rounded w-full">
    <div className="p-4 pl-0">
      <Link to={`/${path}`}>
        <h2 className="font-bold text-xl text-gray-800">{title}</h2>
      </Link>

      {description && (
        <>
          <p className="text-gray-800 mt-2">{description}</p>
        </>
      )}
    </div>
  </div>
)

EventCard.propTypes = {
  title: PropTypes.string.isRequired,
  description: PropTypes.string,
  path: PropTypes.string,
}

export default EventCard
