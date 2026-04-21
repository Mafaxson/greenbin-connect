import { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

export default function Admin() {
  const [heroImages, setHeroImages] = useState([])
  const [partners, setPartners] = useState([])
  const [faqs, setFaqs] = useState([])
  const [waitlist, setWaitlist] = useState([])
  const [activeTab, setActiveTab] = useState('hero')

  useEffect(() => {
    if (activeTab === 'hero') fetchHeroImages()
    else if (activeTab === 'partners') fetchPartners()
    else if (activeTab === 'faqs') fetchFaqs()
    else if (activeTab === 'waitlist') fetchWaitlist()
  }, [activeTab])

  const fetchHeroImages = async () => {
    const { data, error } = await supabase
      .from('hero_images')
      .select('*')
      .order('sort_order')
    if (!error) setHeroImages(data || [])
  }

  const fetchPartners = async () => {
    const { data, error } = await supabase
      .from('partners')
      .select('*')
      .order('name')
    if (!error) setPartners(data || [])
  }

  const fetchFaqs = async () => {
    const { data, error } = await supabase
      .from('faqs')
      .select('*')
      .order('sort_order')
    if (!error) setFaqs(data || [])
  }

  const fetchWaitlist = async () => {
    const { data, error } = await supabase
      .from('waitlist_submissions')
      .select('*')
      .order('created_at', { ascending: false })
    if (!error) setWaitlist(data || [])
  }

  const exportCSV = () => {
    const csv = [
      ['Name', 'Phone', 'Email', 'User Type', 'Area', 'Bins Needed', 'Service Interest', 'Notes', 'Created At'],
      ...waitlist.map(item => [
        item.full_name,
        item.phone,
        item.email,
        item.user_type,
        item.area || '',
        item.bins_needed || '',
        item.service_interest || '',
        item.notes || '',
        item.created_at
      ])
    ].map(row => row.map(cell => `"${cell}"`).join(',')).join('\n')

    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'waitlist_submissions.csv'
    a.click()
  }

  const toggleActive = async (table, id, currentActive) => {
    const { error } = await supabase
      .from(table)
      .update({ active: !currentActive })
      .eq('id', id)

    if (!error) {
      if (table === 'hero_images') fetchHeroImages()
      else if (table === 'partners') fetchPartners()
      else if (table === 'faqs') fetchFaqs()
    }
  }

  const deleteItem = async (table, id) => {
    if (!confirm('Are you sure you want to delete this item?')) return

    const { error } = await supabase
      .from(table)
      .delete()
      .eq('id', id)

    if (!error) {
      if (table === 'hero_images') fetchHeroImages()
      else if (table === 'partners') fetchPartners()
      else if (table === 'faqs') fetchFaqs()
    }
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'DM Sans, sans-serif' }}>
      <h1 style={{ fontSize: '2rem', marginBottom: '2rem', color: '#0d2b1a' }}>GreenBin Connect Admin</h1>

      <div style={{ display: 'flex', gap: '1rem', marginBottom: '2rem', borderBottom: '1px solid #e0e0e0', paddingBottom: '1rem' }}>
        {['hero', 'partners', 'faqs', 'waitlist'].map(tab => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            style={{
              padding: '0.5rem 1rem',
              border: 'none',
              background: activeTab === tab ? '#2d6a4f' : '#f0f0f0',
              color: activeTab === tab ? 'white' : '#333',
              borderRadius: '4px',
              cursor: 'pointer',
              textTransform: 'capitalize'
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      {activeTab === 'hero' && (
        <div>
          <h2>Hero Images</h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '1rem', marginTop: '1rem' }}>
            {heroImages.map(image => (
              <div key={image.id} style={{ border: '1px solid #ddd', padding: '1rem', borderRadius: '8px' }}>
                <img src={image.image_url} alt="Hero" style={{ width: '100%', height: '150px', objectFit: 'cover', borderRadius: '4px' }} />
                <div style={{ marginTop: '0.5rem' }}>
                  <button onClick={() => toggleActive('hero_images', image.id, image.active)}>
                    {image.active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button onClick={() => deleteItem('hero_images', image.id)} style={{ marginLeft: '0.5rem', color: 'red' }}>
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'partners' && (
        <div>
          <h2>Partners</h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '1rem', marginTop: '1rem' }}>
            {partners.map(partner => (
              <div key={partner.id} style={{ border: '1px solid #ddd', padding: '1rem', borderRadius: '8px' }}>
                <img src={partner.logo_url} alt={partner.name} style={{ width: '100%', height: '60px', objectFit: 'contain' }} />
                <h3>{partner.name}</h3>
                <p>{partner.website_url}</p>
                <p>{partner.description}</p>
                <div style={{ marginTop: '0.5rem' }}>
                  <button onClick={() => toggleActive('partners', partner.id, partner.active)}>
                    {partner.active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button onClick={() => deleteItem('partners', partner.id)} style={{ marginLeft: '0.5rem', color: 'red' }}>
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'faqs' && (
        <div>
          <h2>FAQs</h2>
          <div style={{ marginTop: '1rem' }}>
            {faqs.map(faq => (
              <div key={faq.id} style={{ border: '1px solid #ddd', padding: '1rem', marginBottom: '1rem', borderRadius: '8px' }}>
                <h3>{faq.question}</h3>
                <p>{faq.answer}</p>
                <div style={{ marginTop: '0.5rem' }}>
                  <button onClick={() => toggleActive('faqs', faq.id, faq.active)}>
                    {faq.active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button onClick={() => deleteItem('faqs', faq.id)} style={{ marginLeft: '0.5rem', color: 'red' }}>
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'waitlist' && (
        <div>
          <h2>Waitlist Submissions</h2>
          <button onClick={exportCSV} style={{ marginBottom: '1rem', padding: '0.5rem 1rem', background: '#2d6a4f', color: 'white', border: 'none', borderRadius: '4px' }}>
            Export CSV
          </button>
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ background: '#f0f0f0' }}>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Name</th>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Phone</th>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Email</th>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Type</th>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Area</th>
                  <th style={{ padding: '0.5rem', border: '1px solid #ddd' }}>Created</th>
                </tr>
              </thead>
              <tbody>
                {waitlist.map(item => (
                  <tr key={item.id}>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{item.full_name}</td>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{item.phone}</td>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{item.email}</td>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{item.user_type}</td>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{item.area}</td>
                    <td style={{ padding: '0.5rem', border: '1px solid #ddd' }}>{new Date(item.created_at).toLocaleDateString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}